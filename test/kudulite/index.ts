import chalk from "chalk";
import { IConfig } from './interfaces';
import {
  MEST_IMAGE_PREFIX,
  DEFAULT_SRC_CONTAINER_NAME,
  DEFAULT_DEST_CONTAINER_NAME,
  RuntimeImageType
} from './constants';
import {
  Host20Python36,
  Host20Python37,
  Host30Python36,
  Host30Python37,
  Host30Python38,
  Host20Node8,
  Host20Node10,
  Host30Node10,
  Host30Node12,
  Host20Dotnet2,
  Host30Dotnet3,
  Host2xPython36CsprojExtensions,
  Host3xPython36CsprojExtensions,
  Host30Python36OverwriteRunFromPackage,
  Host3xPython3xBuildWheel
} from './testcases';

// Flow
// 1. Developer upload src.zip (e.g. python36_src.zip) to source container
// 2. The program will first initialize a KuduLite container for remote build service
// 3. The program will download the source project and run /api/zipdeploy
// 4. The final artifact will be built onto a destination container
// 5. The test will spin up a runtime image and extract artifact content in /home/site/wwwroot
// 6. The test will check if the /api/HttpTrigger endpoint returns 200

async function initialize(): Promise<IConfig> {
  if (process.argv.length < 3) {
    console.error(chalk.red.bold("Usage: ts-node kudulite <image-name>"));
    console.error(chalk.red.bold("Example:"));
    console.error(chalk.red.bold("    ts-node kudulite mcr.microsoft.com/azure-functions/kudulite:kudu-2.11"));
    process.exit(1);
  }

  if (!process.env.STORAGE_ACCOUNT_NAME) {
    console.error(chalk.red.bold("process.env.STORAGE_ACCOUNT_NAME is required"));
    console.error(chalk.red.bold("This is the storage account name to the src project zips and dest artifacts"));
    process.exit(1);
  }

  if (!process.env.STORAGE_ACCOUNT_KEY) {
    console.error(chalk.red.bold("process.env.STORAGE_ACCOUNT_KEY is required"));
    console.error(chalk.red.bold("This is the storage account key to the src project zips and dest artifacts"));
    process.exit(1);
  }

  if (!process.env.V2_RUNTIME_VERSION) {
    console.error(chalk.red.bold("process.env.V2_RUNTIME_VERSION is required"));
    console.error(chalk.red.bold("This defines the v2 runtime image version tags (e.g. 2.0.14248)"));
    process.exit(1);
  }

  if (!process.env.V3_RUNTIME_VERSION) {
    console.error(chalk.red.bold("process.env.V3_RUNTIME_VERSION is required"));
    console.error(chalk.red.bold("This defines the v3 runtime image version tags (e.g. 3.0.14287)"));
    process.exit(1);
  }

  if (!process.env.TEST_RUNTIME_IMAGE || !(process.env.TEST_RUNTIME_IMAGE in RuntimeImageType)) {
    console.error(chalk.red.bold("process.env.TEST_RUNTIME_IMAGE is required"));
    console.error(chalk.red.bold("This defines the runtime image that will test the built artifact"));
    console.error(chalk.red.bold(`(e.g. ${Object.values(RuntimeImageType)})`));
    process.exit(1);
  }

  const storageConnectionString = 'DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;' +
    `AccountName=${process.env.STORAGE_ACCOUNT_NAME};` +
    `AccountKey=${process.env.STORAGE_ACCOUNT_KEY}`;

  return {
    kuduliteImage: process.argv.reverse()[0],
    storageAccountName: process.env.STORAGE_ACCOUNT_NAME,
    storageAccountKey: process.env.STORAGE_ACCOUNT_KEY,
    v2RuntimeVersion: process.env.V2_RUNTIME_VERSION,
    v3RuntimeVersion: process.env.V3_RUNTIME_VERSION,
    storageConnectionString: storageConnectionString,
    testRuntimeImageType: RuntimeImageType[process.env.TEST_RUNTIME_IMAGE as keyof typeof RuntimeImageType],
    srcContainerName: DEFAULT_SRC_CONTAINER_NAME,
    destContainerName: DEFAULT_DEST_CONTAINER_NAME
  }
}

async function main() {
  const config: IConfig = await initialize();

  // Dotnet
  const testHost20Dotnet2 = new Host20Dotnet2();
  const testHost30Dotnet3 = new Host30Dotnet3();

  // Python
  const testHost20Python36 = new Host20Python36();
  const testHost20Python37 = new Host20Python37();
  const testHost30Python36 = new Host30Python36();
  const testPython36BuildWheel = new Host3xPython3xBuildWheel('3.6');
  const testHost30Python37 = new Host30Python37();
  const testPython37BuildWheel = new Host3xPython3xBuildWheel('3.7');
  const testHost30Python38 = new Host30Python38();
  const testPython38BuildWheel = new Host3xPython3xBuildWheel('3.8');

  // Node
  const testHost20Node8 = new Host20Node8();
  const testHost20Node10 = new Host20Node10();
  const testHost30Node10 = new Host30Node10();
  const testHost30Node12 = new Host30Node12();

  // Special Cases
  const testOverwriteAppSetting = new Host30Python36OverwriteRunFromPackage();
  const testHost20Python36Extensions = new Host2xPython36CsprojExtensions();
  const testHost21Python36Extensions = new Host2xPython36CsprojExtensions();
  const testHost22Python36Extensions = new Host2xPython36CsprojExtensions();
  const testHost30Python36Extensions = new Host3xPython36CsprojExtensions();

  try {
    // CI disk space limitation hit, fail to run all tests parallelly.
    switch (config.testRuntimeImageType) {
      case RuntimeImageType.V2:
        await testHost20Dotnet2.run(config, 'KuduLiteDotnet2.zip', `${MEST_IMAGE_PREFIX}:${config.v2RuntimeVersion}`);
        await testHost20Python36.run(config, 'KuduLitePython36.zip', `${MEST_IMAGE_PREFIX}:${config.v2RuntimeVersion}`);
        await testHost20Node8.run(config, 'KuduLiteNode8.zip', `${MEST_IMAGE_PREFIX}:${config.v2RuntimeVersion}`);
        await testHost21Python36Extensions.run(config, 'KuduLitePython36Extension21.zip', `${MEST_IMAGE_PREFIX}:${config.v2RuntimeVersion}`);
        await testHost20Python36Extensions.run(config, 'KuduLitePython36Extension20.zip', `${MEST_IMAGE_PREFIX}:${config.v2RuntimeVersion}`);
        await testHost22Python36Extensions.run(config, 'KuduLitePython36Extension22.zip', `${MEST_IMAGE_PREFIX}:${config.v2RuntimeVersion}`);
        break;
      case RuntimeImageType.V2_NODE10:
        await testHost20Node10.run(config, 'KuduLiteNode10.zip', `${MEST_IMAGE_PREFIX}:${config.v2RuntimeVersion}-node10`);
        break;
      case RuntimeImageType.V2_PYTHON37:
        await testHost20Python37.run(config, 'KuduLitePython37.zip', `${MEST_IMAGE_PREFIX}:${config.v2RuntimeVersion}-python3.7`);
        break;
      case RuntimeImageType.V3:
        await testHost30Dotnet3.run(config, 'KuduLiteDotnet3.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}`);
        await testHost30Python36.run(config, 'KuduLitePython36.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}`);
        await testPython36BuildWheel.run(config, 'KuduLitePythonBuildWheel.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}`);
        await testHost30Node10.run(config, 'KuduLiteNode10.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}`);
        await testOverwriteAppSetting.run(config, 'KuduLitePython36.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}`);
        await testHost30Python36Extensions.run(config, 'KuduLitePython36Extension30.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}`);
        break;
      case RuntimeImageType.V3_NODE12:
        await testHost30Node12.run(config, 'KuduLiteNode12.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}-node12`);
        break;
      case RuntimeImageType.V3_PYTHON37:
        await testHost30Python37.run(config, 'KuduLitePython37.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}-python3.7`);
        await testPython37BuildWheel.run(config, 'KuduLitePythonBuildWheel.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}-python3.7`);
        break;
      case RuntimeImageType.V3_PYTHON38:
        await testHost30Python38.run(config, 'KuduLitePython38.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}-python3.8`);
        await testPython38BuildWheel.run(config, 'KuduLitePythonBuildWheel.zip', `${MEST_IMAGE_PREFIX}:${config.v3RuntimeVersion}-python3.8`);
        break;
      default:
        throw new Error("Unknown RuntimeImageType");
    }
  } catch (error) {
    console.log(chalk.red.bold(error));
    process.exit(1)
  }
}

main();