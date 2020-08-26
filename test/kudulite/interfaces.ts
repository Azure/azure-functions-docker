export interface IRuntimeImages {
  // Python
  host20python36mesh: string;
  host20python37mesh: string;
  host30python36mesh: string;
  host30python37mesh: string;
  host30python38mesh: string;

  // Node
}

export interface IConfig {
  testImageName: string;
  storageAccountName: string;
  storageAccountKey: string;
  storageConnectionString: string;
  srcContainerName: string;
  destContainerName: string;
}

export interface IContainerStartContext {
  SiteId: number;
  SiteName: string;
  Environment: Record<string, string>
}

export interface ITestCase {
  run: (config: IConfig) => Promise<void>;
}
