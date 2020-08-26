import axios from "axios";
import fs from "fs";
import chalk from "chalk";
import path from "path";
import shell from "shelljs";
import { BlobServiceClient, ContainerClient, generateBlobSASQueryParameters, BlobSASPermissions, StorageSharedKeyCredential } from "@azure/storage-blob";
import { timeout, retry } from './utils';
import { IConfig } from './interfaces';

export class KuduContainer {
  static envVars: Record<string, string> = {
    CONTAINER_ENCRYPTION_KEY: 'MDEyMzQ1Njc4OUFCQ0RFRjAxMjM0NTY3ODlBQkNERUY=',
    WEBSITE_AUTH_ENCRYPTION_KEY: 'E782F47415EEC076F8087729FB30CF1CA1482610C2FA985E4F22531225722205'
  }

  // Map of containerId -> port mapping
  static ports: Record<string, number> = {}
  private createdDate: Date;
  private containerId: string;
  private containerName: string;
  private storageCredential: StorageSharedKeyCredential;
  private storageClient: BlobServiceClient;
  private srcContainerClient: ContainerClient;
  private destContainerClient: ContainerClient;
  private tempFolderPath: string;

  constructor(private config: IConfig) {
    this.createdDate = new Date();
    this.containerId = this.getUniqueContainerId();
    this.containerName = `kudulite${this.containerId}`;
    this.storageCredential = new StorageSharedKeyCredential(config.storageAccountName, config.storageAccountKey);
    this.storageClient = new BlobServiceClient(`https://${config.storageAccountName}.blob.core.windows.net`, this.storageCredential);
    this.srcContainerClient = this.storageClient.getContainerClient(config.srcContainerName);
    this.destContainerClient = this.storageClient.getContainerClient(config.destContainerName);

    this.tempFolderPath = path.join('/tmp', 'kudulite_test', this.containerId);
    fs.mkdirSync(this.tempFolderPath, { recursive: true });
    console.log(chalk.green(`Created temporary folder ${this.tempFolderPath} for testing kudulite image`));
  }

  // Download the source project onto local file system
  public async downloadSrcBlob(srcBlobName: string): Promise<string> {
    console.log(chalk.yellow(`Downloading source package ${srcBlobName}...`));
    await this.srcContainerClient.createIfNotExists();

    const blobClient = this.srcContainerClient.getBlockBlobClient(srcBlobName);
    const localSrcPath = path.join(this.tempFolderPath, srcBlobName)
    try {
      await blobClient.downloadToFile(localSrcPath);
    } catch (error) {
      console.log(chalk.red.bold(`Failed to retrieve src zip ${srcBlobName}`));
      console.log(chalk.red.bold(error));
      throw error;
    }

    console.log(chalk.green(`Downloaded source package ${srcBlobName} to ${localSrcPath}`));
    return localSrcPath;
  }

  public async generateDestBlobSas(destBlobName: string) {
    const artifactName = `${this.containerId}_${destBlobName}`;
    console.log(chalk.yellow(`Generating blob sas uri for artifact storage ${artifactName}...`));

    await this.destContainerClient.createIfNotExists();

    const startsOn = new Date();
    const expiresOn = new Date();
    expiresOn.setHours(expiresOn.getHours() + 1);

    const permission = new BlobSASPermissions();
    permission.create = true;
    permission.read = true;
    const credential = this.storageClient.credential as StorageSharedKeyCredential;
    const sas = generateBlobSASQueryParameters({
      containerName: this.config.destContainerName,
      blobName: artifactName,
      permissions: permission,
      startsOn,
      expiresOn
    }, credential);

    const sasUri = `${this.destContainerClient.url}/${artifactName}?${sas}`;
    console.log(chalk.green(`Generated destination blob sas ${this.destContainerClient.url}/${artifactName}?sv=...`));
    return sasUri;
  }

  public async startContainer(extraEnvVars: Record<string, any> = {}) {
    console.log(chalk.yellow(`Starting container ${this.containerId} for testing...`));

    // Start container with run command, with environment variables
    let runCommand = `docker run -p 0:80 -d --name ${this.containerName}`;
    runCommand += ` -e CONTAINER_NAME=${this.containerName}`;
    runCommand += ` -e WEBSITE_SITE_NAME=${this.containerName}`;
    runCommand += ` -e WEBSITE_HOSTNAME=${this.containerName}.azurewebsites.net`;
    for (const [key, value] of Object.entries(KuduContainer.envVars)) {
      runCommand += ` -e ${key}="${value}"`;
    }
    for (const [key, value] of Object.entries(extraEnvVars)) {
      runCommand += ` -e ${key}="${value}"`;    }
    runCommand += ` ${this.config.testImageName}`;

    // Execute docker command
    if (shell.exec(runCommand).code !== 0) {
      const errorMessage = `Failed to start ${this.containerName} from image ${this.config.testImageName}`;
      throw new Error(errorMessage);
    }

    // Registered current container's port
    const portCommand = `docker port ${this.containerName}`
    const portResult = shell.exec(portCommand);
    if (portResult.code !== 0) {
      console.log(chalk.red.bold(`Failed to find port for ${this.containerName}`));
    }
    const port = portResult.stdout.split(':').reverse()[0];
    KuduContainer.ports[this.containerName] = parseInt(port);

    console.log(chalk.green(`Created container ${this.containerName} at port ${port}`))

    // Wait for the container to spin up
    await timeout(5_000);
  }

  public async applyAppSettings(settings: Record<string, any> = {}) {
    console.log(chalk.yellow(`Applying application settings to ${this.containerName}...`));
    await retry(async () => {
      return await axios.post(`${this.url}/api/settings`, settings, {
        headers: {
          'x-ms-site-restricted-token': this.config.siteRestrictedToken,
          'Content-Type': 'application/json'
        },
        // No need to throw exception on user errors
        validateStatus: (status) => status >= 200 && status <= 499
      });
    });
  }

  public async getAppSettings(): Promise<Record<string, string>> {
    console.log(chalk.yellow(`Getting application settings from ${this.containerName}...`));
    const response = await retry(async () => {
      return await axios.get(`${this.url}/api/settings`, {
        headers: {
          'x-ms-site-restricted-token': this.config.siteRestrictedToken,
          'Content-Type': 'application/json'
        },
        // No need to throw exception on user errors
        validateStatus: (status) => status >= 200 && status <= 499
      });
    });
    return response.data as Record<string, string>;
  }

  public async createZipDeploy(zipLocalPath: string, queryParams: Record<string, string>={}) {
    console.log(chalk.yellow(`Initiate remote build ${zipLocalPath} to ${this.containerId}...`));
    const file = fs.readFileSync(zipLocalPath);
    const params = Object.entries(queryParams).map(([key, value]) => `${key}=${value}`).join('&');

    await retry(async () => {
      return await axios.post(`${this.url}/api/zipdeploy?${params}`, file, {
        headers: {
          'x-ms-site-restricted-token': this.config.siteRestrictedToken,
          'Content-Type': 'application/octet-stream'
        }
      })
    });

    console.log(chalk.green(`Remote build finished and uploaded to destination blob sas.`));
  }

  public killContainer(): void {
    console.log(chalk.yellow(`Killing container ${this.containerId}...`));
    const killCommand = `docker kill ${this.containerName}`
    const killResult = shell.exec(killCommand);
    if (killResult.code !== 0) {
      console.log(chalk.red.bold(`Failed to kill container ${this.containerName}`));
    }

    delete KuduContainer.ports[this.containerName];
    console.log(chalk.green(`Container ${this.containerName} is deleted`));
  }

  public async testBuiltArtifact(baseImage: string, blobSasUri: string) {
    const sanitizedBaseImage = baseImage.replace(/mcr.microsoft.com\/azure-functions\/|\:|\-|\./g, '')
    const destImageTag = `kudulite/test:${sanitizedBaseImage}_${this.containerId}`;
    const destContainerName = `${sanitizedBaseImage}_${this.containerId}`;
    const dockerfileName = `${sanitizedBaseImage}_${this.containerId}.Dockerfile`;
    const dockerfilePath = path.join(this.tempFolderPath, dockerfileName);

    // Generate docker file in temporary folder
    console.log(chalk.yellow(`Generating docker file in ${dockerfilePath}...`));
    fs.writeFileSync(dockerfilePath, `
FROM ${baseImage}

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \\
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \\
    WEBSITE_INSTANCE_ID=mock_app_service_environment

RUN apt-get update \\
    && apt-get install squashfs-tools wget

RUN wget -k -X GET -O ./artifact.squashfs -q '${blobSasUri}' \\
    && mkdir -p /home/site/wwwroot \\
    && unsquashfs -d /home/site/wwwroot -f ./artifact.squashfs
    `);

    // Build runtime image from temporary docker file
    console.log(chalk.yellow(`Building docker image ${destImageTag}...`));
    const buildCommand = `docker build -t ${destImageTag} -f ${dockerfilePath} --no-cache .`;
    const buildResult = shell.exec(buildCommand);
    if (buildResult.code !== 0) {
      const errorMessage = `Failed to build runtime image ${destImageTag}`;
      throw new Error(errorMessage);
    }

    // Run runtime image in a docker container
    console.log(chalk.yellow(`Starting docker container ${destContainerName} from ${destImageTag}`));
    const runCommand = `docker run -p 0:80 -d --name ${destContainerName} ${destImageTag}`;
    console.log(runCommand);
    if (shell.exec(runCommand).code !== 0) {
      const errorMessage = `Failed to start ${destContainerName} from runtime image ${destImageTag}`;
      throw new Error(errorMessage);
    }

    // Registered current container's port
    const portCommand = `docker port ${destContainerName}`;
    const portResult = shell.exec(portCommand);
    if (portResult.code !== 0) {
      console.log(chalk.red.bold(`Failed to find port for ${destContainerName}`));
    }
    const port = portResult.stdout.split(':').reverse()[0];
    KuduContainer.ports[destContainerName] = parseInt(port);

    // Redirect Stdout and Stderr
    const containerLog = shell.exec(`docker logs -f ${destContainerName}`, {
      async: true
    });
    containerLog.stdout && containerLog.stdout.pipe(process.stdout);
    containerLog.stderr && containerLog.stderr.pipe(process.stderr);

    // Initiate an HTTP request to /api/HttpTrigger and see if it returns 200
    console.log(chalk.yellow(`Testing /api/HttpTrigger endpoint in ${destContainerName}`));
    let success = false;
    const runtimeHttpTriggerUrl = `http://127.0.0.1:${KuduContainer.ports[destContainerName]}/api/HttpTrigger`;
    try {
      await retry(async () => await axios.get(runtimeHttpTriggerUrl));
      success = true;
    } catch (error) {
      console.log(chalk.red.bold(`Test FAILED on ${destContainerName} /api/HttpTrigger : ${error}`));
      success = false;
    } finally {
      // Clean up container
      const killCommand = `docker rm -f ${destContainerName}`;
      const killResult = shell.exec(killCommand);
      if (killResult.code !== 0) {
        console.log(chalk.red.bold(`Failed to kill runtime container ${destContainerName}`));
      }

      // Clean up docker image
      const rmiCommand = `docker rmi ${destImageTag}`;
      const rmiResult = shell.exec(rmiCommand);
      if (rmiResult.code !== 0) {
        console.log(chalk.red.bold(`Failed to remove runtime image ${destImageTag}`));
      }

      delete KuduContainer.ports[destContainerName];
    }

    if (success) {
      console.log(chalk.green(`Test PASSED on runtime container ${destContainerName}`));
    } else {
      throw new Error(`Test FAILED on runtime container ${destContainerName}`);
    }
  }

  public get id(): string {
    return this.containerId;
  }

  public get name(): string {
    return this.containerName;
  }

  public get port(): number | undefined {
    return KuduContainer.ports[this.containerName];
  }

  public get url(): string | undefined {
    return `http://127.0.0.1:${this.port}`
  }

  private getUniqueContainerId(): string {
    const date = `${this.createdDate.getUTCFullYear()}${this.createdDate.getUTCMonth() + 1}${this.createdDate.getUTCDate()}`;
    const time = `${this.createdDate.getUTCHours()}${this.createdDate.getUTCMinutes()}${this.createdDate.getUTCSeconds()}`;
    const random = Math.floor(Math.random() * 1000000).toString();
    return `${date}${time}_${random}`;
  }
}