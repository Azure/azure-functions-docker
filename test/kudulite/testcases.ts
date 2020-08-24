import { ITestCase, IConfig } from "./interfaces";
import { KuduContainer } from "./containers";

export class Host20Python36 implements ITestCase {
  public async run(config: IConfig): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.generateDestBlobSas('host20_python36_dest.zip');
    const settings = {
      "ENABLE_ORYX_BUILD": true,
      "SCM_DO_BUILD_DURING_DEPLOYMENT": true,
      "ENABLE_DYNAMIC_INSTALL": true,
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.6",
      "FRAMEWORK_VERSION": "3.6",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    await container.startContainer(settings);
    const localSrcPath = await container.downloadSrcBlob('KuduLitePython36.zip');
    await container.applyAppSettings(settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact('mcr.microsoft.com/azure-functions/python:2.0-python3.6', destSas);
    container.killContainer();
  }
}

export class Host20Python37 implements ITestCase {
  public async run(config: IConfig): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.generateDestBlobSas('host20_python37_dest.zip');
    const settings = {
      "ENABLE_ORYX_BUILD": true,
      "SCM_DO_BUILD_DURING_DEPLOYMENT": true,
      "ENABLE_DYNAMIC_INSTALL": true,
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.7",
      "FRAMEWORK_VERSION": "3.7",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    await container.startContainer(settings);
    const localSrcPath = await container.downloadSrcBlob('KuduLitePython37.zip');
    await container.applyAppSettings(settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact('mcr.microsoft.com/azure-functions/python:3.0-python3.7', destSas);
    container.killContainer();
  }
}

export class Host30Python36 implements ITestCase {
  public async run(config: IConfig): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.generateDestBlobSas('host30_python36_dest.zip');
    const settings = {
      "ENABLE_ORYX_BUILD": true,
      "SCM_DO_BUILD_DURING_DEPLOYMENT": true,
      "ENABLE_DYNAMIC_INSTALL": true,
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.6",
      "FRAMEWORK_VERSION": "3.6",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    await container.startContainer(settings);
    const localSrcPath = await container.downloadSrcBlob('KuduLitePython36.zip');
    await container.applyAppSettings(settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact('mcr.microsoft.com/azure-functions/python:3.0-python3.6', destSas);
    container.killContainer();
  }
}

export class Host30Python37 implements ITestCase {
  public async run(config: IConfig): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.generateDestBlobSas('host30_python37_dest.zip');
    const settings = {
      "ENABLE_ORYX_BUILD": true,
      "SCM_DO_BUILD_DURING_DEPLOYMENT": true,
      "ENABLE_DYNAMIC_INSTALL": true,
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.7",
      "FRAMEWORK_VERSION": "3.7",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    await container.startContainer(settings);
    const localSrcPath = await container.downloadSrcBlob('KuduLitePython37.zip');
    await container.applyAppSettings(settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact('mcr.microsoft.com/azure-functions/python:3.0-python3.7', destSas);
    container.killContainer();
  }
}

export class Host30Python38 implements ITestCase {
  public async run(config: IConfig): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.generateDestBlobSas('host30_python38_dest.zip');
    const settings = {
      "ENABLE_ORYX_BUILD": true,
      "SCM_DO_BUILD_DURING_DEPLOYMENT": true,
      "ENABLE_DYNAMIC_INSTALL": true,
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "python",
      "FRAMEWORK": "python",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "3.8",
      "FRAMEWORK_VERSION": "3.8",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    await container.startContainer(settings);
    const localSrcPath = await container.downloadSrcBlob('KuduLitePython38.zip');
    await container.applyAppSettings(settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact('mcr.microsoft.com/azure-functions/python:3.0-python3.8', destSas);
    container.killContainer();
  }
}

export class Host20Node8 implements ITestCase {
  public async run(config: IConfig): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.generateDestBlobSas('host20_node8_dest.zip');
    const settings = {
      "ENABLE_ORYX_BUILD": true,
      "SCM_DO_BUILD_DURING_DEPLOYMENT": true,
      "ENABLE_DYNAMIC_INSTALL": true,
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "node",
      "FRAMEWORK": "node",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "8",
      "FRAMEWORK_VERSION": "8",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    await container.startContainer(settings);
    const localSrcPath = await container.downloadSrcBlob('KuduLiteNode8.zip');
    await container.applyAppSettings(settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact('mcr.microsoft.com/azure-functions/node:2.0-node8', destSas);
    container.killContainer();
  }
}

export class Host20Node10 implements ITestCase {
  public async run(config: IConfig): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.generateDestBlobSas('host20_node10_dest.zip');
    const settings = {
      "ENABLE_ORYX_BUILD": true,
      "SCM_DO_BUILD_DURING_DEPLOYMENT": true,
      "ENABLE_DYNAMIC_INSTALL": true,
      "FUNCTIONS_EXTENSION_VERSION": "~2",
      "FUNCTIONS_WORKER_RUNTIME": "node",
      "FRAMEWORK": "node",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "10",
      "FRAMEWORK_VERSION": "10",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    await container.startContainer(settings);
    const localSrcPath = await container.downloadSrcBlob('KuduLiteNode10.zip');
    await container.applyAppSettings(settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact('mcr.microsoft.com/azure-functions/node:2.0-node10', destSas);
    container.killContainer();
  }
}

export class Host30Node10 implements ITestCase {
  public async run(config: IConfig): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.generateDestBlobSas('host30_node10_dest.zip');
    const settings = {
      "ENABLE_ORYX_BUILD": true,
      "SCM_DO_BUILD_DURING_DEPLOYMENT": true,
      "ENABLE_DYNAMIC_INSTALL": true,
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "node",
      "FRAMEWORK": "node",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "10",
      "FRAMEWORK_VERSION": "10",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    await container.startContainer(settings);
    const localSrcPath = await container.downloadSrcBlob('KuduLiteNode10.zip');
    await container.applyAppSettings(settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact('mcr.microsoft.com/azure-functions/node:3.0-node10', destSas);
    container.killContainer();
  }
}

export class Host30Node12 implements ITestCase {
  public async run(config: IConfig): Promise<void> {
    const container = new KuduContainer(config);
    const destSas = await container.generateDestBlobSas('host30_node12_dest.zip');
    const settings = {
      "ENABLE_ORYX_BUILD": true,
      "SCM_DO_BUILD_DURING_DEPLOYMENT": true,
      "ENABLE_DYNAMIC_INSTALL": true,
      "FUNCTIONS_EXTENSION_VERSION": "~3",
      "FUNCTIONS_WORKER_RUNTIME": "node",
      "FRAMEWORK": "node",
      "FUNCTIONS_WORKER_RUNTIME_VERSION": "12",
      "FRAMEWORK_VERSION": "12",
      "SCM_RUN_FROM_PACKAGE": destSas
    }
    await container.startContainer(settings);
    const localSrcPath = await container.downloadSrcBlob('KuduLiteNode12.zip');
    await container.applyAppSettings(settings);
    await container.createZipDeploy(localSrcPath);
    await container.testBuiltArtifact('mcr.microsoft.com/azure-functions/node:3.0-node12', destSas);
    container.killContainer();
  }
}