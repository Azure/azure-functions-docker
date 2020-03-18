# escape=`

ARG BASE_IMAGE
ARG CONTENT_URL
FROM mcr.microsoft.com/windows/servercore:ltsc2019 as tools-env
ARG CONTENT_URL

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Invoke-WebRequest -OutFile dotnet.zip "$Env:CONTENT_URL"; `
    Expand-Archive dotnet.zip -DestinationPath C:\approot

FROM ${BASE_IMAGE}

ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY --from=tools-env ["C:\\approot", "C:\\approot"]