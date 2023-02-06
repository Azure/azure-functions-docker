Build Status: [![Build Status](https://azure-functions.visualstudio.com/azure-functions-docker/_apis/build/status/build?branchName=dev)](https://azure-functions.visualstudio.com/azure-functions-docker/_build/latest?definitionId=4&branchName=dev)

CoreTools Healthcheck: [![CoreTools healthcheck](https://azure-functions.visualstudio.com/azure-functions-docker/_apis/build/status/v3%20core-tools%20image%20health%20check?branchName=dev)](https://azure-functions.visualstudio.com/azure-functions-docker/_build/latest?definitionId=43&branchName=dev)

# Host Release Information

Azure-Functions-Docker/host Images : 

Azure-Functions-Docker releases Linux Container Images for Azure-Functions-Host.  These images consist of the[ Azure-Functions-Host](https://github.com/Azure/azure-functions-host), [Extension Bundles](https://github.com/Azure/azure-functions-extension-bundles), and a language worker (ex. [Powershell-Worker](https://github.com/Azure/azure-functions-powershell-worker)).  

Host images have an expected release cadence of once a month. These images are available at the Microsoft Container Registry links visible below.  Versions 3 and 4 are currently being updated in parallel.  Major Version images, those beginning in :3.0 or :4, are the preferred images and will always host the latest released versions after thorough testing and verification. Customers that need a custom image should follow [this documentation for building a custom image](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image). 

There are a variety of Host images that are released. All images contain everything necessary to run Azure-Functions-Host

Images without a suffix are the basic image

-appservice images enable SSH on the Functions-Host container as described for App-Services here : https://docs.microsoft.com/en-us/azure/app-service/configure-linux-open-ssh-session

-slim images are built off of slim base images when possible



# Dockerfiles

Dockerfile artifacts are generated with each release version and uploaded alongside the release notes. 

Release notes for v4.3.0 release : https://github.com/Azure/azure-functions-docker/releases/tag/4.3.0

Artifacts can be downloaded directly here : https://github.com/Azure/azure-functions-docker/releases/download/4.3.0/4.3.0-appservice.zip

# Dockerhub

## V4 Images

#### Dotnet

`mcr.microsoft.com/azure-functions/dotnet`

Linux amd64 Tags

| Tags      | OS Version |
|----------------------|----------------------------------|
| `4`                                      | Debian 11  |
| `4-slim`                                 | Debian 11  |
| `4-appservice` | Debian 11  |
| `4-dotnet6-core-tools` |  Debian 11  |
| `4-appservice-quickstart` | Debian 11 |


`mcr.microsoft.com/azure-functions/dotnet-isolated`

| Tags                                       | OS Version |
|-------------------------------------------|------------|
| `4`                                      | Debian 11  |
| `4-dotnet-isolated5.0-slim`                               | Debian 11 |
| `4-appservice`, `4-dotnet-isolated5.0-appservice` |Debian 11  |
| `4-dotnet-isolated6.0` | Debian 11  |
| `4-dotnet-isolated6.0-core-tools` | Debian 11  |
| `4-dotnet-isolated6.0-appservice-quickstart` | Debian 11 |
| `4-dotnet-isolated7.0` | Debian 11  |
| `4-dotnet-isolated7.0-core-tools` | Debian 11  |
| `4-dotnet-isolated7.0-appservice-quickstart` | Debian 11 |


#### Node

`mcr.microsoft.com/azure-functions/node`

Linux amd64 Tags

| Tags                                      |  OS Version |
|-------------------------------------------|----------------------|
| `4-node14`                              |  Debian 11  |
| `4-node14-slim`                         | Debian 11 |
| `4-node14-appservice`                   |  Debian 11  |
| `4-node14-core-tools`                   |  Debian 11  |
| `4-node14-appservice-quickstart`                     |  Debian 11  |
| `4-node16`                              |  Debian 11  |
| `4-node16-slim`                         |  Debian 11  |
| `4-node16-appservice`                   |  Debian 11  |
| `4-node16-core-tools`                   |  Debian 11  |
| `4-node16-appservice-quickstart`                     |  Debian 11  |
| `4-node18`                              |  Debian 11  |
| `4-node18-slim`                         |  Debian 11  |
| `4-node18-appservice`                   |  Debian 11  |
| `4-node18-core-tools`                   |  Debian 11  |
| `4-node18-appservice-quickstart`                     |  Debian 11  |

#### Powershell

`mcr.microsoft.com/azure-functions/powershell`

Linux amd64 Tags

|Tags               | OS Version |
|----------------------------------|------------|
| `4-powershell7.2`                              |  Debian 11  |
| `4-powershell7.2-slim`                         |  Debian 11  |
| `4-powershell7.2-appservice`                   |  Debian 11  |
| `4-powershell7.2-core-tools`                   | Debian 11 |
| `4-powershell7.2-appservice-quickstart`         |Debian 11  |

#### Java

`mcr.microsoft.com/azure-functions/java`

Linux amd64 Tags

| Tags                                     |  OS Version |
|------------------------------------------|------------|
| `4`, `4-java8`                       |  Debian 11  |
| `4-slim`, `4-java8-slim`             |  Debian 11  |
| `4-appservice`, `4-java8-appservice` |  Debian 11  |
| `4-java8-build`               | Debian 11   |
| `4-java11`                             |Debian 11  |
| `4-java11-slim`                        |  Debian 11  |
| `4-java11-appservice`                  |  Debian 11  |
| `4-java11-core-tools`                  |  Debian 11   |
| `4-java11-build`            | Debian 11  |
| `4-java17`                             |Debian 11  |
| `4-java17-slim`                        |  Debian 11  |
| `4-java17-appservice`                  |  Debian 11  |
| `4-java17-core-tools`                  |  Debian 11   |
| `4-java17-build`            | Debian 11  |
| `4-java17-appservice-quickstart`            | Debian 11  |

### Python

`mcr.microsoft.com/azure-functions/python`

Linux amd64 Tags

| Tags                  | OS Version |
|--------------------------------------------|------------|
| `4-python3.7`                              |  Debian 11  |
| `4-python3.7-slim`                         |  Debian 11  |
| `4-python3.7-appservice`                   |  Debian 11  |
| `4-python3.7-buildenv`                     |  Debian 11  |
| `4-python3.7-core-tools`                   | Debian 11  |
| `4-python3.7-appservice-quickstart`        | Debian 11 |
| `4-python3.8`                              |  Debian 11  |
| `4-python3.8-slim`                         |  Debian 11  |
| `4-python3.8-appservice`                   | Debian 11  |
| `4-python3.8-appservice-quickstart`        | Debian 11 |
| `4-python3.8-buildenv`                     |  Debian 11  |
| `4-python3.8-core-tools`                   | Debian 11  |
| `4-python3.9`                              |  Debian 11  |
| `4-python3.9-slim`                         |  Debian 11  |
| `4-python3.9-appservice`                   |  Debian 11  |
| `4-python3.9-appservice-quickstart`        | Debian 11 |
| `4-python3.9-buildenv`                     | Debian 11  |
| `4-python3.9-core-tools`                   |  Debian 11  |
| `4-python3.10`                             |  Debian 11  |
| `4-python3.10-slim`                        |  Debian 11  |
| `4-python3.10-appservice`                  |  Debian 11  |
| `4-python3.10-buildenv`                    | Debian 11  |
| `4-python3.10-core-tools`                  |  Debian 11  |
| `4-python3.10-appservice-quickstart`        | Debian 11 |

#### Base

`mcr.microsoft.com/azure-functions/base`

Linux amd64 Tags

| Tags             | OS Version |
|------------------|------------|
| `4`            |  Debian 11  |
| `4-slim`       |  Debian 11  |
| `4-appservice` |  Debian 11  |

#### MCR Docs

For new images update the following:

- [MCR Syndication](https://github.com/microsoft/mcr/blob/main/teams/azurefunctions/azure-functions.yml)

- [Docs on DockerHub](https://github.com/microsoft/mcrdocs/tree/main/teams/azurefunctions)

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
