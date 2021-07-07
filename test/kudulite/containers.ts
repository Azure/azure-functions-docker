import axios from "axios";
import fs from "fs";
import chalk from "chalk";
import path from "path";
import shell from "shelljs";
import { BlobServiceClient, ContainerClient, generateBlobSASQueryParameters, BlobSASPermissions, StorageSharedKeyCredential } from "@azure/storage-blob";
import { timeout, retry, getSiteRestirctedTokenFromBase64, getEncryptedContextFromBase64 } from './utils';
import { IConfig } from './interfaces';

export class KuduContainer {
  static envVars: Record<string, string> = {
    CONTAINER_ENCRYPTION_KEY: 'MDEyMzQ1Njc4OUFCQ0RFRjAxMjM0NTY3ODlBQkNERUY=',
    WEBSITE_PLACEHOLDER_MODE: '1',
    WEBSITE_MOUNT_ENABLED: '0' // because on windows local testing /dev/fuse is not available
  }

  // Map of container name -> port mapping
  static ports: Record<string, number> = {}
  private createdDate: Date;

  private containerId: string;
  private containerName: string;
  private runtimeContainerName: string;
  private siteName: string;
  private siteRestrictedToken: string;

  private storageCredential: StorageSharedKeyCredential;
  private storageClient: BlobServiceClient;
  private srcContainerClient: ContainerClient;
  private destContainerClient: ContainerClient;
  private tempFolderPath: string;

  constructor(private config: IConfig) {
    this.createdDate = new Date();

    this.containerId = this.getUniqueContainerId();
    this.containerName = `kudulite${this.containerId}`;
    this.runtimeContainerName = `runtime${this.containerId}`;
    this.siteName = `site${this.containerId}`;
    this.siteRestrictedToken = getSiteRestirctedTokenFromBase64(KuduContainer.envVars.CONTAINER_ENCRYPTION_KEY);
    this.storageCredential = new StorageSharedKeyCredential(config.storageAccountName, config.storageAccountKey);
    this.storageClient = new BlobServiceClient(`https://${config.storageAccountName}.blob.core.windows.net`, this.storageCredential);
    this.srcContainerClient = this.storageClient.getContainerClient(config.srcContainerName);
    this.destContainerClient = this.storageClient.getContainerClient(config.destContainerName);
    this.tempFolderPath = path.join('/tmp', 'kudulite_test', `${this.containerId}`);

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

  public async getDestBlobSas() {
    const artifactName = `rfp-latest-${this.siteName}.squashfs`;
    console.log(chalk.yellow(`Getting blob sas uri for artifact storage ${artifactName}...`));

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
    console.log(chalk.green(`Destination blob sas ${this.destContainerClient.url}/${artifactName}?sv=...`));
    return sasUri;
  }

  public async startKuduLiteContainer(extraEnvVars: Record<string, any> = {}): Promise<string> {
    return this.startContainer(this.config.kuduliteImage, this.containerName, extraEnvVars);
  }

  public async startRuntimeContainer(image: string, extraEnvVars: Record<string, any> = {}): Promise<string> {
    return this.startContainer(image, this.runtimeContainerName, extraEnvVars);
  }

  private async startContainer(image: string, name: string, extraEnvVars: Record<string, any>): Promise<string> {
    console.log(chalk.yellow(`Starting container ${this.containerId} for testing...`));

    // Start container with run command, with environment variables
    let runCommand = `docker run -p 0:80 -d --name ${name} -e CONTAINER_NAME="${name}"`;
    Object.entries(KuduContainer.envVars).forEach(([key, value]) => runCommand += ` -e ${key}="${value}"`);
    Object.entries(extraEnvVars).forEach(([key, value]) => runCommand += ` -e ${key}="${value}"`);
    runCommand += ` ${image}`;

    // Execute docker command
    let retryCount: number = 10;
    while (shell.exec(runCommand).code !== 0 && retryCount > 0) {
      // Clean up mesh images
      this.cleanUpMeshImages();
      await timeout(10_000);
      retryCount -= 1;
    }
    // Retry Fails
    if (retryCount <= 0) {
      const errorMessage = `Failed to start ${name} from image ${image}`;
      throw new Error(errorMessage);
    }

    // Wait for port to be established
    await timeout(1_000);

    // Registered current container's port
    const portCommand = `docker port ${name}`;
    const portResult = shell.exec(portCommand);
    if (portResult.code !== 0) {
      console.log(chalk.red.bold(`Failed to find port for ${name}`));
    }
    const port = portResult.stdout.split(':').reverse()[0];
    KuduContainer.ports[name] = parseInt(port);
    console.log(chalk.green(`Created container ${name} at port ${port}`))

    // Return container name
    return name;
  }

  public async healthCheck(name: string) {
    // Used for checking if the home page is accessible to public
    // This endpoint is used during specialization
    const baseUrl = `http://127.0.0.1:${KuduContainer.ports[name]}`;
    await retry(async () => {
      return await axios.get(`${baseUrl}`, {
        validateStatus: (status: number) => status >= 200 && status <= 499
      });
    });
  }

  public async assignContainer(name: string, environmentVariables: Record<string, string>) {
    console.log(chalk.yellow(`Assign container ${name} at port ${KuduContainer.ports[name]}...`));
    const encryptionKey = KuduContainer.envVars.CONTAINER_ENCRYPTION_KEY;
    const encryptedContext = getEncryptedContextFromBase64(encryptionKey, {
      SiteId: parseInt(this.containerId.substring(0, 8)),
      SiteName: name,
      Environment: {
        ...environmentVariables,
        WEBSITE_SITE_NAME: this.siteName
      }
    })

    const baseUrl = `http://127.0.0.1:${KuduContainer.ports[name]}`;
    await retry(async () => {
      return await axios.post(`${baseUrl}/admin/instance/assign`, {
        encryptedContext: encryptedContext,
        isWarmup: false
      }, {
        headers: {
          'x-ms-site-restricted-token': this.siteRestrictedToken,
          'Content-Type': 'application/json'
        },
        // No need to throw exception on user errors
        validateStatus: (status: number) => status >= 200 && status <= 499
      });
    });
  }

  public async applyAppSettings(name: string, settings: Record<string, any> = {}) {
    console.log(chalk.yellow(`Applying application settings to ${name}...`));
    const baseUrl = `http://127.0.0.1:${KuduContainer.ports[name]}`;
    await retry(async () => {
      return await axios.post(`${baseUrl}/api/settings`, settings, {
        headers: {
          'x-ms-site-restricted-token': this.siteRestrictedToken,
          'Content-Type': 'application/json'
        },
        // No need to throw exception on user errors
        validateStatus: (status) => status >= 200 && status <= 499
      });
    });
  }

  public async getAppSettings(name: string): Promise<Record<string, string>> {
    console.log(chalk.yellow(`Getting application settings from ${name}...`));
    const baseUrl = `http://127.0.0.1:${KuduContainer.ports[name]}`;
    const response = await retry(async () => {
      return await axios.get(`${baseUrl}/api/settings`, {
        headers: {
          'x-ms-site-restricted-token': this.siteRestrictedToken,
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

    const baseUrl = `http://127.0.0.1:${KuduContainer.ports[this.containerName]}`;
    await retry(async () => {
      return await axios.post(`${baseUrl}/api/zipdeploy?${params}`, file, {
        headers: {
          'x-ms-site-restricted-token': this.siteRestrictedToken,
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

  public async testBuiltArtifact(baseImage: string, environmentVariables: Record<string, string>) {
    const destContainerName = this.runtimeContainerName;

    // Pull down the base image and kick start the runtime in it
    console.log(chalk.yellow(`Testing built artifact with ${baseImage} on ${destContainerName}}`));
    const runtimeName = await this.startRuntimeContainer(baseImage, environmentVariables);
    const baseUrl = `http://127.0.0.1:${KuduContainer.ports[runtimeName]}`;

    // Redirect stdout and stderr
    // const containerLog = shell.exec(`docker logs -f ${destContainerName}`, { async: true });
    // containerLog.stdout && containerLog.stdout.pipe(process.stdout);
    // containerLog.stderr && containerLog.stderr.pipe(process.stderr);

    // Specialize container
    console.log(chalk.yellow(`Specializing /admin/instance/assign endpoint in ${destContainerName}...`));
    await this.assignContainer(this.runtimeContainerName, environmentVariables);

    // Initiate an HTTP request to /api/HttpTrigger and see if it returns 200
    console.log(chalk.yellow(`Testing /api/HttpTrigger endpoint in ${destContainerName}...`));
    let success = false;
    const runtimeHttpTriggerUrl = `${baseUrl}/api/HttpTrigger`;
    try {
      await retry(async () => await axios.get(runtimeHttpTriggerUrl, {
        headers: {
          'x-site-deployment-id': this.siteName
        }
      }));
      success = true;
    } catch (error) {
      console.log(chalk.red.bold(`Test FAILED on ${destContainerName} /api/HttpTrigger : ${error}`));
      success = false;
    } finally {
      // Clean up container
      console.log(chalk.yellow(`Cleaning up container ${destContainerName}...`));
      const killCommand = `docker rm -f ${destContainerName}`;
      const killResult = shell.exec(killCommand);
      if (killResult.code !== 0) {
        console.log(chalk.red.bold(`Failed to kill runtime container ${destContainerName}`));
      }

      // Remove ports registry
      delete KuduContainer.ports[destContainerName];
    }

    if (success) {
      console.log(chalk.green(`Test PASSED on runtime container ${destContainerName}`));
    } else {
      throw new Error(`Test FAILED on runtime container ${destContainerName}`);
    }
  }

  private getUniqueContainerId(): string {
    //YYYYMMDDhhmmss + random 3 digits
    const datetime = this.createdDate.toISOString().substring(0, 19).replace(/T|Z|\:|\.|\-/g, '')
    const random = Math.floor(Math.random() * 1000).toString();
    return `${datetime}${random}`;
  }

  private cleanUpMeshImages(): void {
    // Retry by removing other images
    console.log(chalk.yellow(`Cleaning up mesh images to free up space...`));
    const meshPrefix = 'mcr.microsoft.com/azure-functions/mesh';
    const rmiCommand = `docker rmi -f $(docker images ${meshPrefix} -q)`;
    const rmiResult = shell.exec(rmiCommand);
    if (rmiResult.code !== 0) {
      console.log(chalk.red.bold(`Failed to remove mesh images`));
    }
  }
}