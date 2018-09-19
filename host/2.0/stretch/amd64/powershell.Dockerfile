ARG BASE_IMAGE_TAG=dev
ARG WORKER_TAG=0.1.10-alpha
FROM azure-functions/base:${BASE_IMAGE_TAG}
ARG BASE_IMAGE_TAG
ARG WORKER_TAG

RUN apt-get update && \
    apt-get install -y git wget unzip

RUN mkdir PowerShellWorker && cd PowerShellWorker && \
    wget -q -O PowerShellWorker.nupkg https://www.myget.org/F/azure-appservice/api/v2/package/Microsoft.Azure.Functions.PowerShellWorker/${WORKER_TAG} && \
    unzip -q PowerShellWorker.nupkg && \
    mv ./contentFiles/any/any/workers/powershell ../azure-functions-host/workers/powershell
