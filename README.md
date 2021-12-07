Build Status: [![Build Status](https://azure-functions.visualstudio.com/azure-functions-docker/_apis/build/status/build?branchName=dev)](https://azure-functions.visualstudio.com/azure-functions-docker/_build/latest?definitionId=4&branchName=dev)

CoreTools Healthcheck: [![CoreTools healthcheck](https://azure-functions.visualstudio.com/azure-functions-docker/_apis/build/status/v3%20core-tools%20image%20health%20check?branchName=dev)](https://azure-functions.visualstudio.com/azure-functions-docker/_build/latest?definitionId=43&branchName=dev)

# Dockerhub

## V4 Images

#### Dotnet

`mcr.microsoft.com/azure-functions/dotnet`

Linux amd64 Tags

| Tags                                       | Dockerfile                                                              | OS Version |
|--------------------------------------------|-------------------------------------------------------------------------|------------|
| `4`                                      | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-inproc/dotnet.Dockerfile)            | Debian 10  |
| `4-slim`                                 | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-inproc/dotnet-slim.Dockerfile)       | Debian 10  |
| `4-appservice`, `4-dotnet3-appservice` | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-inproc/dotnet-appservice.Dockerfile) | Debian 10  |
| `4-dotnet3-core-tools` | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-inproc/dotnet-core-tools.Dockerfile) | Debian 10  |


`mcr.microsoft.com/azure-functions/dotnet-isolated`

| Tags                                       | Dockerfile                                                              | OS Version |
|--------------------------------------------|-------------------------------------------------------------------------|------------|
| `4`                                      | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-isolated/dotnet-isolated.Dockerfile)            | Debian 10  |
| `4-dotnet-isolated5.0-slim`                                 | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-isolated/dotnet-isolated-slim.Dockerfile)       | Debian 10  |
| `4-appservice`, `4-dotnet-isolated5.0-appservice` | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-isolated/dotnet-isolated-appservice.Dockerfile) | Debian 10  |
| `4-dotnet-isolated5.0-core-tools` | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-isolated/dotnet-isolated-core-tools.Dockerfile) | Debian 10  |

#### Node

`mcr.microsoft.com/azure-functions/node`

Linux amd64 Tags

| Tags                                      | Dockerfile                                                                   | OS Version |
|-------------------------------------------|------------------------------------------------------------------------------|------------|
| `4-node14`                              | [Dockerfile](host/4/bullseye/amd64/node/node14/node14.Dockerfile)            | Debian 10  |
| `4-node14-slim`                         | [Dockerfile](host/4/bullseye/amd64/node/node14/node14-slim.Dockerfile)       | Debian 10  |
| `4-node14-appservice`                   | [Dockerfile](host/4/bullseye/amd64/node/node14/node14-appservice.Dockerfile) | Debian 10  |
| `4-node14-core-tools`                   | [Dockerfile](host/4/bullseye/amd64/node/node14/node14-core-tools.Dockerfile) | Debian 10  |
| `4-node16`                              | [Dockerfile](host/4/bullseye/amd64/node/node16/node16.Dockerfile)            | Debian 10  |
| `4-node16-slim`                         | [Dockerfile](host/4/bullseye/amd64/node/node16/node16-slim.Dockerfile)       | Debian 10  |
| `4-node16-appservice`                   | [Dockerfile](host/4/bullseye/amd64/node/node16/node16-appservice.Dockerfile) | Debian 10  |
| `4-node16-core-tools`                   | [Dockerfile](host/4/bullseye/amd64/node/node16/node16-core-tools.Dockerfile) | Debian 10  |

#### Powershell

`mcr.microsoft.com/azure-functions/powershell`

Linux amd64 Tags

| Tags                                           | Dockerfile                                                                       | OS Version |
|------------------------------------------------|----------------------------------------------------------------------------------|------------|
| `4`, `4-powershell6`                       | [Dockerfile](host/4/bullseye/amd64/powershell/powershell6.Dockerfile)            | Debian 10  |
| `4-slim`, `4-powershell6-slim`             | [Dockerfile](host/4/bullseye/amd64/powershell/powershell6-slim.Dockerfile)       | Debian 10  |
| `4-appservice`, `4-powershell6-appservice` | [Dockerfile](host/4/bullseye/amd64/powershell/powershell6-appservice.Dockerfile) | Debian 10  |
| `4-powershell6-core-tools`                   | [Dockerfile](host/4/bullseye/amd64/powershell/powershell6-core-tools.Dockerfile) | Debian 10   |
| `4-powershell7`                              | [Dockerfile](host/4/bullseye/amd64/powershell/powershell7.Dockerfile)            | Debian 10  |
| `4-powershell7-slim`                         | [Dockerfile](host/4/bullseye/amd64/powershell/powershell7-slim.Dockerfile)       | Debian 10  |
| `4-powershell7-appservice`                   | [Dockerfile](host/4/bullseye/amd64/powershell/powershell7-appservice.Dockerfile) | Debian 10  |
| `4-powershell7-core-tools`                   | [Dockerfile](host/4/bullseye/amd64/powershell/powershell7-core-tools.Dockerfile) | Debian 10  |

#### Java

`mcr.microsoft.com/azure-functions/java`

Linux amd64 Tags

| Tags                                     | Dockerfile                                                           | OS Version |
|------------------------------------------|----------------------------------------------------------------------|------------|
| `4`, `4-java8`                       | [Dockerfile](host/4/bullseye/amd64/java/java8/java8.Dockerfile)            | Debian 10  |
| `4-slim`, `4-java8-slim`             | [Dockerfile](host/4/bullseye/amd64/java/java8/java8-slim.Dockerfile)       | Debian 10  |
| `4-appservice`, `4-java8-appservice` | [Dockerfile](host/4/bullseye/amd64/java/java8/java8-appservice.Dockerfile) | Debian 10  |
| `4-java8-core-tools`                   | [Dockerfile](host/4/bullseye/amd64/java/java8/java8-core-tools.Dockerfile) | Debian 10   |
| `4-java8-build`                        | `N/A`                                                                        | Debian 10   |
| `4-java11`                             | [Dockerfile](host/4/bullseye/amd64/java/java11/java11.Dockerfile)            | Debian 10  |
| `4-java11-slim`                        | [Dockerfile](host/4/bullseye/amd64/java/java11/java11-slim.Dockerfile)       | Debian 10  |
| `4-java11-appservice`                  | [Dockerfile](host/4/bullseye/amd64/java/java11/java11-appservice.Dockerfile) | Debian 10  |
| `4-java11-core-tools`                  | [Dockerfile](host/4/bullseye/amd64/java/java11/java11-core-tools.Dockerfile) | Debian 10   |
| `4-java11-build`                       | `N/A`                                                                        | Debian 10  |


### Python

`mcr.microsoft.com/azure-functions/python`

Linux amd64 Tags

| Tags                                         | Dockerfile                                                                         | OS Version |
|----------------------------------------------|------------------------------------------------------------------------------------|------------|
| `4-python3.8`                              | [Dockerfile](host/4/bullseye/amd64/python/python38/python38.Dockerfile)            | Debian 10  |
| `4-python3.8-slim`                         | [Dockerfile](host/4/bullseye/amd64/python/python38/python38-slim.Dockerfile)       | Debian 10  |
| `4-python3.8-appservice`                   | [Dockerfile](host/4/bullseye/amd64/python/python38/python38-appservice.Dockerfile) | Debian 10  |
| `4-python3.8-buildenv`                     | [Dockerfile](host/4/bullseye/amd64/python/python38/python38-buildenv.Dockerfile)   | Debian 10  |
| `4-python3.8-core-tools`                   | [Dockerfile](host/4/bullseye/amd64/python/python38/python38-core-tools.Dockerfile) | Debian 10  |
| `4-python3.9`                              | [Dockerfile](host/4/bullseye/amd64/python/python39/python39.Dockerfile)            | Debian 10  |
| `4-python3.9-slim`                         | [Dockerfile](host/4/bullseye/amd64/python/python39/python39-slim.Dockerfile)       | Debian 10  |
| `4-python3.9-appservice`                   | [Dockerfile](host/4/bullseye/amd64/python/python39/python39-appservice.Dockerfile) | Debian 10  |
| `4-python3.9-buildenv`                     | [Dockerfile](host/4/bullseye/amd64/python/python39/python39-buildenv.Dockerfile)   | Debian 10  |
| `4-python3.9-core-tools`                   | [Dockerfile](host/4/bullseye/amd64/python/python39/python39-core-tools.Dockerfile) | Debian 10  |

#### Base

`mcr.microsoft.com/azure-functions/base`

Linux amd64 Tags

| Tags             | Dockerfile                                                              | OS Version |
|------------------|-------------------------------------------------------------------------|------------|
| `4`            | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet.Dockerfile)            | Debian 10  |
| `4-slim`       | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-slim.Dockerfile)       | Debian 10  |
| `4-appservice` | [Dockerfile](host/4/bullseye/amd64/dotnet/dotnet-appservice.Dockerfile) | Debian 10  |

## V3 Images

#### Dotnet

`mcr.microsoft.com/azure-functions/dotnet`

Linux amd64 Tags

| Tags                                       | Dockerfile                                                              | OS Version |
|--------------------------------------------|-------------------------------------------------------------------------|------------|
| `3.0`                                      | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-inproc/dotnet.Dockerfile)            | Debian 10  |
| `3.0-slim`                                 | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-inproc/dotnet-slim.Dockerfile)       | Debian 10  |
| `3.0-appservice`, `3.0-dotnet3-appservice` | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-inproc/dotnet-appservice.Dockerfile) | Debian 10  |
| `3.0-dotnet3-core-tools` | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-inproc/dotnet-core-tools.Dockerfile) | Debian 10  |


`mcr.microsoft.com/azure-functions/dotnet-isolated`

| Tags                                       | Dockerfile                                                              | OS Version |
|--------------------------------------------|-------------------------------------------------------------------------|------------|
| `3.0`                                      | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-isolated/dotnet-isolated.Dockerfile)            | Debian 10  |
| `3.0-dotnet-isolated5.0-slim`                                 | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-isolated/dotnet-isolated-slim.Dockerfile)       | Debian 10  |
| `3.0-appservice`, `3.0-dotnet-isolated5.0-appservice` | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-isolated/dotnet-isolated-appservice.Dockerfile) | Debian 10  |
| `3.0-dotnet-isolated5.0-core-tools` | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-isolated/dotnet-isolated-core-tools.Dockerfile) | Debian 10  |

Linux arm32v7 Tags

| Tags                 | Dockerfile                                                     | OS Version   |
|----------------------|----------------------------------------------------------------|--------------|
| `3.0-arm32v7`        | [Dockerfile](host/3.0/buster/arm32v7/dotnet/dotnet.Dockerfile) | Debian 10    |
| `3.0-bionic-arm32v7` | [Dockerfile](host/3.0/bionic/arm32v7/dotnet/dotnet.Dockerfile) | Ubuntu 18.04 |

Windows Server

| Tags                  | Dockerfile                                               | OS Version          |
|-----------------------|----------------------------------------------------------|---------------------|
| `3.0-nanoserver-1809` | [Dockerfile](host/3.0/nanoserver/1809/dotnet.Dockerfile) | Windows Server 1809 |

#### Node

`mcr.microsoft.com/azure-functions/node`

Linux amd64 Tags

| Tags                                      | Dockerfile                                                                   | OS Version |
|-------------------------------------------|------------------------------------------------------------------------------|------------|
| `3.0`, `3.0-node10`                       | [Dockerfile](host/3.0/buster/amd64/node/node10/node10.Dockerfile)            | Debian 10  |
| `3.0-slim`, `3.0-node10-slim`             | [Dockerfile](host/3.0/buster/amd64/node/node10/node10-slim.Dockerfile)       | Debian 10  |
| `3.0-appservice`, `3.0-node10-appservice` | [Dockerfile](host/3.0/buster/amd64/node/node10/node10-appservice.Dockerfile) | Debian 10  |
| `3.0-core-tools`, `3.0-node10-core-tools` | [Dockerfile](host/3.0/buster/amd64/node/node10/node10-core-tools.Dockerfile) | Debian 9  |
| `3.0-node12`                              | [Dockerfile](host/3.0/buster/amd64/node/node12/node12.Dockerfile)            | Debian 10  |
| `3.0-node12-slim`                         | [Dockerfile](host/3.0/buster/amd64/node/node12/node12-slim.Dockerfile)       | Debian 10  |
| `3.0-node12-appservice`                   | [Dockerfile](host/3.0/buster/amd64/node/node12/node12-appservice.Dockerfile) | Debian 10  |
| `3.0-node12-core-tools`                   | [Dockerfile](host/3.0/buster/amd64/node/node12/node12-core-tools.Dockerfile) | Debian 9  |
| `3.0-node14`                              | [Dockerfile](host/3.0/buster/amd64/node/node14/node14.Dockerfile)            | Debian 10  |
| `3.0-node14-slim`                         | [Dockerfile](host/3.0/buster/amd64/node/node14/node14-slim.Dockerfile)       | Debian 10  |
| `3.0-node14-appservice`                   | [Dockerfile](host/3.0/buster/amd64/node/node14/node14-appservice.Dockerfile) | Debian 10  |
| `3.0-node14-core-tools`                   | [Dockerfile](host/3.0/buster/amd64/node/node14/node14-core-tools.Dockerfile) | Debian 9  |

#### Powershell

`mcr.microsoft.com/azure-functions/powershell`

Linux amd64 Tags

| Tags                                           | Dockerfile                                                                       | OS Version |
|------------------------------------------------|----------------------------------------------------------------------------------|------------|
| `3.0`, `3.0-powershell6`                       | [Dockerfile](host/3.0/buster/amd64/powershell/powershell6.Dockerfile)            | Debian 10  |
| `3.0-slim`, `3.0-powershell6-slim`             | [Dockerfile](host/3.0/buster/amd64/powershell/powershell6-slim.Dockerfile)       | Debian 10  |
| `3.0-appservice`, `3.0-powershell6-appservice` | [Dockerfile](host/3.0/buster/amd64/powershell/powershell6-appservice.Dockerfile) | Debian 10  |
| `3.0-powershell6-core-tools`                   | [Dockerfile](host/3.0/buster/amd64/powershell/powershell6-core-tools.Dockerfile) | Debian 9   |
| `3.0-powershell7`                              | [Dockerfile](host/3.0/buster/amd64/powershell/powershell7.Dockerfile)            | Debian 10  |
| `3.0-powershell7-slim`                         | [Dockerfile](host/3.0/buster/amd64/powershell/powershell7-slim.Dockerfile)       | Debian 10  |
| `3.0-powershell7-appservice`                   | [Dockerfile](host/3.0/buster/amd64/powershell/powershell7-appservice.Dockerfile) | Debian 10  |
| `3.0-powershell7-core-tools`                   | [Dockerfile](host/3.0/buster/amd64/powershell/powershell7-core-tools.Dockerfile) | Debian 10  |

#### Java

`mcr.microsoft.com/azure-functions/java`

Linux amd64 Tags

| Tags                                     | Dockerfile                                                           | OS Version |
|------------------------------------------|----------------------------------------------------------------------|------------|
| `3.0`, `3.0-java8`                       | [Dockerfile](host/3.0/buster/amd64/java/java8/java8.Dockerfile)            | Debian 10  |
| `3.0-slim`, `3.0-java8-slim`             | [Dockerfile](host/3.0/buster/amd64/java/java8/java8-slim.Dockerfile)       | Debian 10  |
| `3.0-appservice`, `3.0-java8-appservice` | [Dockerfile](host/3.0/buster/amd64/java/java8/java8-appservice.Dockerfile) | Debian 10  |
| `3.0-java8-core-tools`                   | [Dockerfile](host/3.0/buster/amd64/java/java8/java8-core-tools.Dockerfile) | Debian 10   |
| `3.0-java8-build`                        | `N/A`                                                                        | Debian 10   |
| `3.0-java11`                             | [Dockerfile](host/3.0/buster/amd64/java/java11/java11.Dockerfile)            | Debian 10  |
| `3.0-java11-slim`                        | [Dockerfile](host/3.0/buster/amd64/java/java11/java11-slim.Dockerfile)       | Debian 10  |
| `3.0-java11-appservice`                  | [Dockerfile](host/3.0/buster/amd64/java/java11/java11-appservice.Dockerfile) | Debian 10  |
| `3.0-java11-core-tools`                  | [Dockerfile](host/3.0/buster/amd64/java/java11/java11-core-tools.Dockerfile) | Debian 10   |
| `3.0-java11-build`                       | `N/A`                                                                        | Debian 10  |


### Python

`mcr.microsoft.com/azure-functions/python`

Linux amd64 Tags

| Tags                                         | Dockerfile                                                                         | OS Version |
|----------------------------------------------|------------------------------------------------------------------------------------|------------|
| `3.0`, `3.0-python3.6`                       | [Dockerfile](host/3.0/buster/amd64/python/python36/python36.Dockerfile)            | Debian 10  |
| `3.0-slim`, `3.0-python3.6-slim`             | [Dockerfile](host/3.0/buster/amd64/python/python36/python36-slim.Dockerfile)       | Debian 10  |
| `3.0-appservice`, `3.0-python3.6-appservice` | [Dockerfile](host/3.0/buster/amd64/python/python36/python36-appservice.Dockerfile) | Debian 10  |
| `3.0-python3.6-buildenv`                     | [Dockerfile](host/3.0/buster/amd64/python/python36/python36-buildenv.Dockerfile)   | Debian 10  |
| `3.0-python3.7`                              | [Dockerfile](host/3.0/buster/amd64/python/python37/python37.Dockerfile)            | Debian 10  |
| `3.0-python3.7-slim`                         | [Dockerfile](host/3.0/buster/amd64/python/python37/python37-slim.Dockerfile)       | Debian 10  |
| `3.0-python3.7-appservice`                   | [Dockerfile](host/3.0/buster/amd64/python/python37/python37-appservice.Dockerfile) | Debian 10  |
| `3.0-python3.7-buildenv`                     | [Dockerfile](host/3.0/buster/amd64/python/python37/python37-buildenv.Dockerfile)   | Debian 10  |
| `3.0-python3.8`                              | [Dockerfile](host/3.0/buster/amd64/python/python38/python38.Dockerfile)            | Debian 10  |
| `3.0-python3.8-slim`                         | [Dockerfile](host/3.0/buster/amd64/python/python38/python38-slim.Dockerfile)       | Debian 10  |
| `3.0-python3.8-appservice`                   | [Dockerfile](host/3.0/buster/amd64/python/python38/python38-appservice.Dockerfile) | Debian 10  |
| `3.0-python3.8-buildenv`                     | [Dockerfile](host/3.0/buster/amd64/python/python38/python38-buildenv.Dockerfile)   | Debian 10  |
| `3.0-python3.8-core-tools`                   | [Dockerfile](host/3.0/buster/amd64/python/python38/python38-core-tools.Dockerfile) | Debian 10  |
| `3.0-python3.9`                              | [Dockerfile](host/3.0/buster/amd64/python/python39/python39.Dockerfile)            | Debian 10  |
| `3.0-python3.9-slim`                         | [Dockerfile](host/3.0/buster/amd64/python/python39/python39-slim.Dockerfile)       | Debian 10  |
| `3.0-python3.9-appservice`                   | [Dockerfile](host/3.0/buster/amd64/python/python39/python39-appservice.Dockerfile) | Debian 10  |
| `3.0-python3.9-buildenv`                     | [Dockerfile](host/3.0/buster/amd64/python/python39/python39-buildenv.Dockerfile)   | Debian 10  |
| `3.0-python3.9-core-tools`                   | [Dockerfile](host/3.0/buster/amd64/python/python39/python39-core-tools.Dockerfile) | Debian 10  |

#### Base

`mcr.microsoft.com/azure-functions/base`

Linux amd64 Tags

| Tags             | Dockerfile                                                              | OS Version |
|------------------|-------------------------------------------------------------------------|------------|
| `3.0`            | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet.Dockerfile)            | Debian 10  |
| `3.0-slim`       | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-slim.Dockerfile)       | Debian 10  |
| `3.0-appservice` | [Dockerfile](host/3.0/buster/amd64/dotnet/dotnet-appservice.Dockerfile) | Debian 10  |

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