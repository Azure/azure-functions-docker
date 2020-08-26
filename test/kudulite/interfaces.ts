export interface IConfig {
  testImageName: string;
  storageAccountName: string;
  storageAccountKey: string;
  storageConnectionString: string;
  siteRestrictedToken: string;
  srcContainerName: string;
  destContainerName: string;
}

export interface ITestCase {
  run: (config: IConfig) => Promise<void>;
}