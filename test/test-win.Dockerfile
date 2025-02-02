# escape=`

ARG BASE_IMAGE
ARG CONTENT_PKG
FROM mcr.microsoft.com/windows/servercore:ltsc2019 as tools-env
ARG CONTENT_PKG

COPY ${CONTENT_PKG} dotnet.zip

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Expand-Archive dotnet.zip -DestinationPath C:\approot

FROM ${BASE_IMAGE}

ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY --from=tools-env ["C:\\approot", "C:\\approot"]