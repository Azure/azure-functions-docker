ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/python
ARG BASE_IMAGE_TAG=dev-seabreeze

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs

ADD https://www.myget.org/F/azure-appservice/api/v2/package/Microsoft.Azure.Functions.PowerShellWorker/0.1.32-alpha PowerShellWorker.nupkg

RUN apt-get update && \
    apt-get install -y unzip && \
    unzip -q PowerShellWorker.nupkg && \
    mv contentFiles/any/any/workers/powershell azure-functions-host/workers/powershell
