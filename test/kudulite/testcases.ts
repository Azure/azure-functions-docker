import { ITestCase, IConfig } from "./interfaces";
import { KuduContainer } from "./containers";

// Host 2.0 Dotnet2 /api/zipdeploy
export class Host20Dotnet2 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "dotnet",
      "FRAMEWORK": "dotnet",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "2",
      "FRAMEWORK_VERSION": "2",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Dotnet3 /api/zipdeploy
export class Host30Dotnet3 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "dotnet",
      "FRAMEWORK": "dotnet",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3",
      "FRAMEWORK_VERSION": "3",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 2.0 Python36 /api/zipdeploy
export class Host20Python36 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.6",
      "FRAMEWORK_VERSION": "3.6",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 2.0 Python37 /api/zipdeploy
export class Host20Python37 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.7",
      "FRAMEWORK_VERSION": "3.7",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Python36 /api/zipdeploy
export class Host30Python36 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.6",
      "FRAMEWORK_VERSION": "3.6",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Python37 /api/zipdeploy
export class Host30Python37 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.7",
      "FRAMEWORK_VERSION": "3.7",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Python38 /api/zipdeploy
export class Host30Python38 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.8",
      "FRAMEWORK_VERSION": "3.8",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 2.0 Node8 /api/zipdeploy
export class Host20Node8 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "node",
      "FRAMEWORK": "node",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "8",
      "FRAMEWORK_VERSION": "8",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 2.0 Node10 /api/zipdeploy
export class Host20Node10 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "node",
      "FRAMEWORK": "node",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "10",
      "FRAMEWORK_VERSION": "10",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Node10 /api/zipdeploy
export class Host30Node10 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "node",
      "FRAMEWORK": "node",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "10",
      "FRAMEWORK_VERSION": "10",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Node12 /api/zipdeploy
export class Host30Node12 implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "node",
      "FRAMEWORK": "node",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "12",
      "FRAMEWORK_VERSION": "12",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Python36 /api/zipdeploy?overwriteWebsiteRunFromPackage=true
export class Host30Python36OverwriteRunFromPackage implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "AzureWebJobsStorage": config.storageConnectionString,
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.6",
      "FRAMEWORK_VERSION": "3.6",
      "WEBSITE_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath, {
      overwriteWebsiteRunFromPackage: 'true'
    });
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 2.x Python36 /api/zipdeploy with extensions.csproj
// For testing function app without extension bundle
export class Host2xPython36CsprojExtensions implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "AzureWebJobsStorage": config.storageConnectionString,
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.6",
      "FRAMEWORK_VERSION": "3.6",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Python36 /api/zipdeploy with extensions.csproj
export class Host3xPython36CsprojExtensions implements ITestCase {
  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "AzureWebJobsStorage": config.storageConnectionString,
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.6",
      "FRAMEWORK_VERSION": "3.6",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Python3x /api/zipdeploy with pyodbc, need to build wheel
export class Host3xPython3xBuildWheel implements ITestCase {
  public constructor(private pythonVersion: string) {}

  public async run(config: IConfig, srcPackage: string, runtimeImage: string): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.getDestBlobSas();
    const settings = {
      "AzureWebJobsStorage": config.storageConnectionString,
      "ENABLE_ORYX_BUILD": 'true',
      "SCM_DO_BUILD_DURING_DEPLOYMENT": 'true',
      "ENABLE_DYNAMIC_INSTALL": 'true',
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": this.pythonVersion,
      "FRAMEWORK_VERSION": this.pythonVersion,
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    const kuduliteContainerName = await container.startKuduLiteContainer(settings);
    await container.healthCheck(kuduliteContainerName);
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}