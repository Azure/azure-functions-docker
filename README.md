
# Docker pull command

`docker pull mcr.microsoft.com/azure-functions/base`

# Images

`docker pull mcr.microsoft.com/azure-functions/base`

`docker pull mcr.microsoft.com/azure-functions/dotnet`

`docker pull mcr.microsoft.com/azure-functions/node`

`docker pull mcr.microsoft.com/azure-functions/python`

`docker pull mcr.microsoft.com/azure-functions/powershell`

+ `latest`
+ `2.0`
+ `2.0-arm32v7`

# What is Azure Functions?
Azure Functions is an event driven, compute-on-demand experience that extends the existing Azure application platform with capabilities to implement code triggered by events occurring in virtually any Azure or 3rd party service as well as on-premises systems. Azure Functions allows developers to take action by connecting to data sources or messaging solutions, thus making it easy to process and react to events. Azure Functions scale based on demand and you pay only for the resources you consume.

# How to use this image?

Base image contains just the azure functions runtime. Other images contain a language framework (dotnet, node, or python) as well as the language worker needed by the runtime to understand these functions.

## Supported Tags

### Linux amd64

- `azure-functions/base:2.0` - The latest stable 2.0 function runtime for Linux with no worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/base.Dockerfile).

- `azure-functions/dotnet:2.0` - the latest stable 2.0 function runtime for Linux with dotnet worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/base.Dockerfile)

- `azure-functions/node:2.0` - the latest stable 2.0 function runtime for Linux with node 10 worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/node.Dockerfile)

- `azure-functions/python:2.0` - the latest stable 2.0 function runtime for Linux with python 3.6 worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/python.Dockerfile)


- `azure-functions/powershell:2.0` - the latest stable 2.0 function runtime for Linux with powershell worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/powershell.Dockerfile)

### Linux arm32v7

- `azure-functions/base:2.0-arm32v7` - The latest stable 2.0 function runtime for Linux with no worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/base.Dockerfile).

- `azure-functions/dotnet:2.0-arm32v7` - the latest stable 2.0 function runtime for Linux with dotnet worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/base.Dockerfile)

- `azure-functions/node:2.0-arm32v7` - the latest stable 2.0 function runtime for Linux with node 10 worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/node.Dockerfile)

- `azure-functions/python:2.0-arm32v7` - the latest stable 2.0 function runtime for Linux with python 3.6 worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/python.Dockerfile)


- `azure-functions/powershell:2.0-arm32v7` - the latest stable 2.0 function runtime for Linux with powershell worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/stretch/amd64/powershell.Dockerfile)

### Windows:

#### nanoserver-1809

- `azure-functions/base:2.0-nanoserver-1809` - The latest stable 2.0 function runtime for nanoserver-1809 with no worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/nanoserver-1809/Dockerfile).

- `azure-functions/dotnet:2.0-nanoserver-1809` - the latest stable 2.0 function runtime for nanoserver-1809 with dotnet worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/nanoserver-1809/Dockerfile)

#### nanoserver-1803

- `azure-functions/base:2.0-nanoserver-1803` - The latest stable 2.0 function runtime for nanoserver-1803 with no worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/nanoserver-1803/Dockerfile).

- `azure-functions/dotnet:2.0-nanoserver-1803` - the latest stable 2.0 function runtime for nanoserver-1803 with dotnet worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/nanoserver-1803/Dockerfile)

#### nanoserver-1709

- `azure-functions/base:2.0-nanoserver-1709` - The latest stable 2.0 function runtime for nanoserver-1709 with no worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/nanoserver-1709/Dockerfile).

- `azure-functions/dotnet:2.0-nanoserver-1709` - the latest stable 2.0 function runtime for nanoserver-1709 with dotnet worker runtime. The Dockerfile can be found [here](https://github.com/Azure/azure-functions-docker/blob/master/host/2.0/nanoserver-1709/Dockerfile)

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
