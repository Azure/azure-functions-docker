[![Build Status](https://azure-functions.visualstudio.com/azure-functions-docker/_apis/build/status/build?branchName=master)](https://azure-functions.visualstudio.com/azure-functions-docker/_build/latest?definitionId=4&branchName=master)

# Dockerhub

## V3 Images


#### Dotnet

`mcr.microsoft.com/azure-functions/dotnet`

Linux amd64 Tags

| Tags     | Dockerfile     | OS Version    |
| -------- | -------------- | ------------- |
| 3.0      | [Dockerfile]() |   Debian 10   |
| 3.0-slim | [Dockerfile]() |   Debian 10   |
| 3.0-appservice, 3.0-dotnet3-appservice, 3.0-appservice-quickstart | [Dockerfile]() | Debian 10 |

Linux arm32v7 Tags

| Tags               | Dockerfile     | OS Version    |
| ------------------ | -------------- | ------------- |
| 3.0-arm32v7        | [Dockerfile]() | Debian 10     |
| 3.0-bionic-arm32v7 | [Dockerfile]() | Ubuntu 18.04  |

Windows Server

| Tags                | Dockerfile     | OS Version          |
| ------------------- | -------------- | ------------------- |
| 3.0-nanoserver-1809 | [Dockerfile]() | Windows Server 1809 |

#### Node

`mcr.microsoft.com/azure-functions/node`

Linux amd64 Tags

| Tags                      | Dockerfile      | OS Version   |
| ------------------------- | --------------- | ------------ |
| 3.0, 3.0-node10           | [Dockerfile]()  | Debian 10    |
| 3.0-slim, 3.0-node10-slim | [Dockerfile]()  | Debian 10    |
| 3.0-appservice, 3.0-appservice-quickstart, 3.0-node10-appservice, 3.0-node10-appservice-quickstart | [Dockerfile]() | Debian 10 |
| 3.0-node12                | [Dockerfile]()  | Debian 10    |
| 3.0-node12-slim           | [Dockerfile]()  | Debian 10    |
| 3.0-node12-appservice, 3.0-node12-appservice-quickstart | [Dockerfile]() | Debian 10 |

#### Powershell

`mcr.microsoft.com/azure-functions/powershell`

Linux amd64 Tags

| Tags                           | Dockerfile      | OS Version   |
| ------------------------------ | --------------- | ------------ |
| 3.0, 3.0-powershell6           | [Dockerfile]()  | Debian 10    |
| 3.0-slim, 3.0-powershell6-slim | [Dockerfile]()  | Debian 10    |
| 3.0-appservice, 3.0-appservice-quickstart, 3.0-powershell6-appservice, 3.0-powershell6-appservice-quickstart | [Dockerfile]() | Debian 10 |

#### Java

`mcr.microsoft.com/azure-functions/java`

Linux amd64 Tags

| Tags                     | Dockerfile      | OS Version   |
| ------------------------ | --------------- | ------------ |
| 3.0, 3.0-java8           | [Dockerfile]()  | Debian 10    |
| 3.0-slim, 3.0-java8-slim | [Dockerfile]()  | Debian 10    |
| 3.0-appservice, 3.0-appservice-quickstart, 3.0-java8-appservice, 3.0-java8-appservice-quickstart | [Dockerfile]() | Debian 10 |
| 3.0-java8-build          | [Dockerfile]()  | Debian 9     |

### Python

`mcr.microsoft.com/azure-functions/python`

Linux amd64 Tags

| Tags                      | Dockerfile      | OS Version   |
| ------------------------- | --------------- | ------------ |
| 3.0, 3.0-python3.6           | [Dockerfile]()  | Debian 10    |
| 3.0-slim, 3.0-python3.6-slim | [Dockerfile]()  | Debian 10    |
| 3.0-appservice, 3.0-appservice-quickstart, 3.0-python3.6-appservice, 3.0-python3.6-appservice-quickstart | [Dockerfile]() | Debian 10 |
| 3.0-python3.6-buildenv       | [Dockerfile]()  | Debian 10    |
| 3.0-python3.7                | [Dockerfile]()  | Debian 10    |
| 3.0-python3.7-slim           | [Dockerfile]()  | Debian 10    |
| 3.0-python3.7-appservice, 3.0-python3.7-appservice-quickstart | [Dockerfile]() | Debian 10 |
| 3.0-python3.7-buildenv       | [Dockerfile]()  | Debian 10    |
| 3.0-python3.8                | [Dockerfile]()  | Debian 10    |
| 3.0-python3.8-slim           | [Dockerfile]()  | Debian 10    |
| 3.0-python3.8-appservice, 3.0-python3.8-appservice-quickstart | [Dockerfile]() | Debian 10 |
| 3.0-python3.8-buildenv       | [Dockerfile]()  | Debian 10    |


## V2 Images

#### Dotnet

`mcr.microsoft.com/azure-functions/dotnet`

Linux amd64 Tags

| Tags     | Dockerfile     | OS Version    |
| -------- | -------------- | ------------- |
| 2.0      | [Dockerfile]() |   Debian 9    |
| 2.0-slim | [Dockerfile]() |   Debian 9    |
| 2.0-appservice, 2.0-dotnet2-appservice, 2.0-appservice-quickstart | [Dockerfile]() | Debian 9 |

Linux arm32v7 Tags

| Tags               | Dockerfile     | OS Version    |
| ------------------ | -------------- | ------------- |
| 2.0-arm32v7        | [Dockerfile]() | Debian 9      |
| 2.0-bionic-arm32v7 | [Dockerfile]() | Ubuntu 18.04  |

Linux alpine Tags

| Tags               | Dockerfile     | OS Version    |
| ------------------ | -------------- | ------------- |
| 2.0-alpine         | [Dockerfile]() | Alpine 3.8    |

Windows Server

| Tags                | Dockerfile     | OS Version          |
| ------------------- | -------------- | ------------------- |
| 2.0-nanoserver-1803 | [Dockerfile]() | Windows Server 1803 |
| 2.0-nanoserver-1809 | [Dockerfile]() | Windows Server 1809 |

#### Node

`mcr.microsoft.com/azure-functions/node`

Linux amd64 Tags

| Tags                      | Dockerfile      | OS Version   |
| ------------------------- | --------------- | ------------ |
| 2.0, 2.0-node8            | [Dockerfile]()  | Debian 9     |
| 2.0-slim, 2.0-node8-slim  | [Dockerfile]()  | Debian 9     |
| 2.0-appservice, 2.0-appservice-quickstart, 2.0-node8-appservice, 2.0-node8-appservice-quickstart | [Dockerfile]() | Debian 9  |
| 2.0-node10                | [Dockerfile]()  | Debian 9     |
| 2.0-node10-slim           | [Dockerfile]()  | Debian 9     |
| 2.0-node10-appservice, 2.0-node10-appservice-quickstart | [Dockerfile]() | Debian 9  |
| 2.0-node12                | [Dockerfile]()  | Debian 9     |
| 2.0-node12-slim           | [Dockerfile]()  | Debian 9     |
| 2.0-node12-appservice, 2.0-node12-appservice-quickstart | [Dockerfile]() | Debian 9  |

Linux alpine Tags

| Tags                         | Dockerfile     | OS Version    |
| ---------------------------- | -------------- | ------------- |
| 2.0-alpine, 2.0-node8-alpine | [Dockerfile]() | Alpine 3.8    |
| 2.0-node10-alpine            | [Dockerfile]() | Alpine 3.8    |
| 2.0-node12-alpine            | [Dockerfile]() | Alpine 3.8    |

#### Powershell

`mcr.microsoft.com/azure-functions/powershell`

Linux amd64 Tags

| Tags                           | Dockerfile      | OS Version   |
| ------------------------------ | --------------- | ------------ |
| 2.0, 2.0-powershell6           | [Dockerfile]()  | Debian 9     |
| 2.0-slim, 2.0-powershell6-slim | [Dockerfile]()  | Debian 9     |
| 2.0-appservice, 2.0-appservice-quickstart, 2.0-powershell6-appservice, 2.0-powershell6-appservice-quickstart | [Dockerfile]() | Debian 9  |

Linux alpine Tags

| Tags                               | Dockerfile     | OS Version    |
| ---------------------------------- | -------------- | ------------- |
| 2.0-alpine, 2.0-powershell6-alpine | [Dockerfile]() | Alpine 3.8    |


#### Java

`mcr.microsoft.com/azure-functions/java`

Linux amd64 Tags

| Tags                     | Dockerfile      | OS Version   |
| ------------------------ | --------------- | ------------ |
| 2.0, 2.0-java8           | [Dockerfile]()  | Debian 9     |
| 2.0-slim, 2.0-java8-slim | [Dockerfile]()  | Debian 9     |
| 2.0-appservice, 2.0-appservice-quickstart, 2.0-java8-appservice, 2.0-java8-appservice-quickstart | [Dockerfile]() | Debian 10 |
| 2.0-java8-build          | [Dockerfile]()  | Debian 9     |

Linux alpine Tags

| Tags                         | Dockerfile     | OS Version    |
| ---------------------------- | -------------- | ------------- |
| 2.0-alpine, 2.0-java8-alpine | [Dockerfile]() | Alpine 3.8    |


### Python

`mcr.microsoft.com/azure-functions/python`

Linux amd64 Tags

| Tags                      | Dockerfile      | OS Version   |
| ------------------------- | --------------- | ------------ |
| 2.0, 2.0-python3.6           | [Dockerfile]()  | Debian 9     |
| 2.0-slim, 2.0-python3.6-slim | [Dockerfile]()  | Debian 9     |
| 2.0-appservice, 2.0-appservice-quickstart, 2.0-python3.6-appservice, 2.0-python3.6-appservice-quickstart | [Dockerfile]() | Debian 9  |
| 2.0-python3.6-buildenv       | [Dockerfile]()  | Debian 9     |
| 2.0-python3.7                | [Dockerfile]()  | Debian 9     |
| 2.0-python3.7-slim           | [Dockerfile]()  | Debian 9     |
| 2.0-python3.7-appservice, 2.0-python3.7-appservice-quickstart | [Dockerfile]() | Debian 9  |
| 2.0-python3.7-buildenv       | [Dockerfile]()  | Debian 9     |
| 2.0-python3.8                | [Dockerfile]()  | Debian 9     |
| 2.0-python3.8-slim           | [Dockerfile]()  | Debian 9     |
| 2.0-python3.8-appservice, 2.0-python3.8-appservice-quickstart | [Dockerfile]() | Debian 9  |
| 2.0-python3.8-buildenv       | [Dockerfile]()  | Debian 9     |

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
