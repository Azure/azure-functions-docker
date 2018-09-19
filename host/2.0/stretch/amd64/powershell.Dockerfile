ARG BASE_IMAGE_TAG=dev
ARG WORKER_TAG=0.1.10-alpha
FROM azure-functions/base:${BASE_IMAGE_TAG}
ARG BASE_IMAGE_TAG
ARG WORKER_TAG

RUN apt-get update && \
    apt-get install -y git wget unzip

RUN mkdir PowerShellWorker && cd PowerShellWorker && \
    wget -q https://ci.appveyor.com/api/buildjobs/7lyurvik90a6h1y2/artifacts/package%2Fbin%2FRelease%2FMicrosoft.Azure.Functions.PowerShellWorker.0.1.10-alpha.nupkg && \
    unzip package%2Fbin%2FRelease%2FMicrosoft.Azure.Functions.PowerShellWorker.${WORKER_TAG}.nupkg && \
    mv ./contentFiles/any/any/workers/powershell ../azure-functions-host/workers/powershell
