import { ITestCase, IConfig } from "./interfaces";
import { KuduContainer } from "./containers";

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
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

// Host 3.0 Python36 /api/zipdeploy?overwriteWebsiteRunFromPackage=true
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
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

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
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

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
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

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
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

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
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

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
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}

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
    const localSrcPath = await container.downloadSrcBlob(srcPackage);
    await container.assignContainer(kuduliteContainerName, settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact(runtimeImage, settings);
    container.killContainer();
  }
}