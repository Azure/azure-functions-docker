# Azure Functions Core Tools Deployment Pipeline

Azure Functions Core Tools image is nightly build and deployed to the production enviornment. 
This document explains how to operation the pipelines. 

## Pipelines
We have two pipelines for Core Tools. 

### v3 Core Tools Publish
This pipeline trigged nightly at 22:00 every night. 

* [v3 Core Tools Publish (private)](https://azure-functions.visualstudio.com/azure-functions-docker/_build?definitionId=42&_a=summary)

This pipeline will

* Fetching the latest version of the Azure Functions Core Tools from npm package. 
* Build and Test the images for (DotNetCore 3, Java, Node, Python) then push to the Private Registry.
* Publish these images from the Private Registry.

The pipeline has several stages. 

| Stage | Responsibility |
| ---- | ---- |
| prepare | Fetch the latest version of Azure Functions Core Tools |
| build | Build and Test the images and publish to the Private Docker Registry with `PrivateVersion` (e.g. 3.0.2534.3) |
| Publish | Pull the images with `PrivateVersion` and Tag and Publish the images with `MajorVersion` (e.g. 3.0) `TargetVersion` (e.g.3.0.2534) |

#### Mode
This pipeline provide several modes. 

##### Full Deployment 

Execute all the pipeline that I explained above. 

_Pipeline Variables_
| Name | Value |
| ---- | ----- |
| BuildOnly | false |
| PublishPrivateVersion | (empty) |
| PublishTargetVersion | (empty) |
| SkipProduction | false |

##### Build Only 

Doesn't execute publish stage. It is used if the Dockerfile is property created.

_Pipeline Variables_
| Name | Value |
| ---- | ----- |
| BuildOnly | true |
| PublishPrivateVersion | (empty) |
| PublishTargetVersion | (empty) |
| SkipProduction | - |

##### Skip Production

It tags the images, however, it is not actually publishing the image to production. 
If you want to test publish stage, this option works. 

_Pipeline Variables_
| Name | Value |
| ---- | ----- |
| BuildOnly | false |
| PublishPrivateVersion | - |
| PublishTargetVersion | - |
| SkipProduction | true |

##### Rollback 

If the image is broken by some reasons, you can rollback the image by this mode. 
This pipeline preserve 7 histories for each images for each versions. 

Under the hood, this pipeline has `PrivateVersion` That is used for private repository. 
It is consist with `TaregetVersion` + `.0` 0 will be (0 - 6). 0 Represents Sunday. 

If you want to Rollback, You can specify the PrivateVersion. The last dight will be 
the weekday (Sunday(0) - Saturday(6)). This operation will only execute `publish` stage. 

_Pipeline Variables_
| Name | Value | sample |
| ---- | ----- | ----- |
| BuildOnly | false | false |
| PublishPrivateVersion | PrivateVersion | 3.0.2534.3 |
| PublishTargetVersion | TargetVersion | 3.0.2534 |
| SkipProduction | false | false |

This pipeline will publish 3.0 version and Tareget version (e.g. 3.0.2534) to the production. 
The target version is the latest Azure Functions Core Tools version that is fetched by func command installed by npm. If you want to test the rollback, you can execute it with `SkipProduction`=true. It is just do the testing. After the rollback, you can execute the health check pipeline that is decribed below. 

### v3 core-tools image health check

This pipeline is trigged every hour. Pull the official images and test the images if it work propery.

* [v3 core-tools image health check (private)](https://azure-functions.visualstudio.com/azure-functions-docker/_build?definitionId=43&_a=summary)

## Trouble Shooting

### Pipeline Fails
Sometime test fails. In the test, we validated that the latest Azure Functions Core Tools version matches the version of the func command that is inside of the container. Inside of the container, the `func` command is installed by `apt-get` package manager. Sometimes, `npm` package is updated before the `apt-get`. You can refer what happens in the log of Azure Pipeline. 
In this case, you can ignore it and wait until the apt-get azure functions core tools package is updated. It might take several days, however, since the test is done by `build and test` stage, it won't publish the new images, so no problem. However, keep your eyes on the helthcheck pipeline. 

### Pipeline has got stuck
Sometimes, I see the issue that Azure Pipelinse stop working during pulling some images. Currently, I don't know the root cause, however, as a workaround, cancel the pipeline and execute it again after waiting for a while. Then  it will success. 


