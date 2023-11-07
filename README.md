Build Status: [![Build Status](https://azure-functions.visualstudio.com/azure-functions-docker/_apis/build/status/build?branchName=dev)](https://azure-functions.visualstudio.com/azure-functions-docker/_build/latest?definitionId=4&branchName=dev)

CoreTools Healthcheck: [![CoreTools healthcheck](https://azure-functions.visualstudio.com/azure-functions-docker/_apis/build/status/v3%20core-tools%20image%20health%20check?branchName=dev)](https://azure-functions.visualstudio.com/azure-functions-docker/_build/latest?definitionId=43&branchName=dev)

# Dockerhub

## V4 Images

See release artifacts for Dockerfiles - example : https://github.com/Azure/azure-functions-docker/releases/download/3.4.2/3.4.2-appservice.zip

Information about how we keep our images up to date can be found [in the wiki](https://github.com/Azure/azure-functions-docker/wiki/Refreshing-Upstream-Dependencies-for-available-non-appservice-images)

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
| `4-dotnet-isolated6.0`                    | Debian 11 |
| `4-dotnet-isolated6.0-slim`               | Debian 11 |
| `4-dotnet-isolated6.0-appservice`         | Debian 11 |
| `4-dotnet-isolated6.0-appservice-quickstart` | Debian 11 |
| `4-dotnet-isolated6.0-core-tools`         | Debian 11 |
| `4-dotnet-isolated7.0`                    | Debian 11 |
| `4-dotnet-isolated7.0-slim`               | Debian 11 |
| `4-dotnet-isolated7.0-appservice`         | Debian 11 |
| `4-dotnet-isolated7.0-appservice-quickstart` | Debian 11 |
| `4-dotnet-isolated8.0`                    | Debian 12 |
| `4-dotnet-isolated8.0-slim`               | Debian 12 |
| `4-dotnet-isolated8.0-appservice`         | Debian 12 |

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
| `4-node20`                              |  Debian 11  |
| `4-node20-slim`                         |  Debian 11  |
| `4-node20-appservice`                   |  Debian 11  |
| `4-node20-core-tools`                   |  Debian 11  |

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
| `4-java8`                             | Debian 11  |
| `4-java8-slim`                        |  Debian 11  |
| `4-java8-appservice`                  |  Debian 11  |
| `4-java8-build`                       | Debian 11   |
| `4-java11`                             |Debian 11  |
| `4-java11-slim`                        |  Debian 11  |
| `4-java11-appservice`                  |  Debian 11  |
| `4-java11-core-tools`                  |  Debian 11   |
| `4-java11-build`                      | Debian 11  |
| `4-java17`                             |Debian 11  |
| `4-java17-slim`                        |  Debian 11  |
| `4-java17-appservice`                  |  Debian 11  |
| `4-java17-core-tools`                  |  Debian 11   |
| `4-java17-build`            | Debian 11  |
| `4-java17-appservice-quickstart`            | Debian 11  |
| `4-java21`                             |Debian 12  |
| `4-java21-slim`                        |  Debian 12  |
| `4-java21-appservice`                  |  Debian 12  |
| `4-java21-core-tools`                  |  Debian 12   |
| `4-java21-build`            | Debian 12  |
| `4-java21-appservice-quickstart`            | Debian 12  |

### Python

`mcr.microsoft.com/azure-functions/python`

Linux amd64 Tags

| Tags                                 | OS Version |
|--------------------------------------|------------|
| `4-python3.7`                        |  Debian 11  |
| `4-python3.7-slim`                   |  Debian 11  |
| `4-python3.7-appservice`             |  Debian 11  |
| `4-python3.7-buildenv`               |  Debian 11  |
| `4-python3.7-core-tools`             | Debian 11  |
| `4-python3.7-appservice-quickstart`  | Debian 11 |
| `4-python3.8`                        |  Debian 11  |
| `4-python3.8-slim`                   |  Debian 11  |
| `4-python3.8-appservice`             | Debian 11  |
| `4-python3.8-appservice-quickstart`  | Debian 11 |
| `4-python3.8-buildenv`               |  Debian 11  |
| `4-python3.8-core-tools`             | Debian 11  |
| `4-python3.9`                        |  Debian 11  |
| `4-python3.9-slim`                   |  Debian 11  |
| `4-python3.9-appservice`             |  Debian 11  |
| `4-python3.9-appservice-quickstart`  | Debian 11 |
| `4-python3.9-buildenv`               | Debian 11  |
| `4-python3.9-core-tools`             |  Debian 11  |
| `4-python3.10`                       |  Debian 11  |
| `4-python3.10-slim`                  |  Debian 11  |
| `4-python3.10-appservice`            |  Debian 11  |
| `4-python3.10-buildenv`              | Debian 11  |
| `4-python3.10-core-tools`            |  Debian 11  |
| `4-python3.10-appservice-quickstart` | Debian 11 |
| `4-python3.11`                       |  Debian 11  |
| `4-python3.11-slim`                  |  Debian 11  |
| `4-python3.11-appservice`            |  Debian 11  |
| `4-python3.11-buildenv`              | Debian 11  |
| `4-python3.11-core-tools`            |  Debian 11  |
| `4-python3.11-appservice-quickstart` | Debian 11 |

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
