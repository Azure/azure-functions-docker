export interface IConfig {
  kuduliteImage: string;
  storageAccountName: string;
  storageAccountKey: string;
  storageConnectionString: string;
  srcContainerName: string;
  destContainerName: string;
  v2RuntimeVersion: string;
  v3RuntimeVersion: string;
}

export interface IContainerStartContext {
  SiteId: number;
  SiteName: string;
  Environment: Record<string, string>
}

export interface ITestCase {
  run: (config: IConfig, srcPackage: string, runtimeImage: string) => Promise<void>;
}
