# escape=`

#Run-time image
ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/dotnet
ARG BASE_IMAGE_TAG=2.0-nanoserver-1803

FROM mcr.microsoft.com/powershell:6.1.0-nanoserver-1803 AS installer-env
ENV NODE_VERSION="8.12.0"

COPY scripts\install_node.ps1 "C:\\temp\\install_node.ps1"
RUN pwsh.exe -executionpolicy bypass -command C:\\temp\\install_node.ps1 -Version $Env:NODE_VERSION

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

#Copy to new container
ARG INSTALLATION_DIR="C:\\Program Files\\nodejs"
COPY --from=installer-env ${INSTALLATION_DIR} ${INSTALLATION_DIR}

#Set the environment variable
RUN setx path "%path%;%ProgramFiles%\nodejs"
