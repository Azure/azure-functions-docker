import chalk from "chalk";
import { IConfig } from './interfaces';
import {
  Host20Python36,
  Host20Python37,
  Host30Python36,
  Host30Python37,
  Host30Python38,
  Host20Node8,
  Host20Node10,
  Host30Node10,
  Host30Node12
} from './testcases'

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

  if (!process.env.SITE_RESTRICTED_TOKEN) {
    console.error(chalk.red.bold("process.env.SITE_RESTRICTED_TOKEN is required"));
    console.error(chalk.red.bold("This is the credential for calling the POST /api/settings to setup remote build"));
    process.exit(1);
  }

  const storageConnectionString = 'DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;' +
    `AccountName=${process.env.STORAGE_ACCOUNT_NAME};` +
    `AccountKey=${process.env.STORAGE_ACCOUNT_KEY}`;

  return {
    testImageName: process.argv.reverse()[0],
    storageAccountName: process.env.STORAGE_ACCOUNT_NAME,
    storageAccountKey: process.env.STORAGE_ACCOUNT_KEY,
    siteRestrictedToken: process.env.SITE_RESTRICTED_TOKEN,
    storageConnectionString: storageConnectionString,
    srcContainerName: 'testsrc',
    destContainerName: 'testdest',
  }
}

async function main() {
  const config: IConfig = await initialize();

  // Python
  const testHost20Python36 = new Host20Python36();
  const testHost20Python37 = new Host20Python37();
  const testHost30Python36 = new Host30Python36();
  const testHost30Python37 = new Host30Python37();
  const testHost30Python38 = new Host30Python38();

  // Node
  const testHost20Node8 = new Host20Node8();
  const testHost20Node10 = new Host20Node10();
  const testHost30Node10 = new Host30Node10();
  const testHost30Node12 = new Host30Node12();

  try {
    await Promise.all([
      testHost20Python36.run(config),
      /*
      testHost20Python37.run(config),
      testHost30Python36.run(config),
      testHost30Python37.run(config),
      testHost30Python38.run(config),
      testHost20Node8.run(config),
      testHost20Node10.run(config),
      testHost30Node10.run(config),
      testHost30Node12.run(config)
      */
    ]);
  } catch (error) {
    console.log(chalk.red.bold(error));
    process.exit(1)
  }
}

main();