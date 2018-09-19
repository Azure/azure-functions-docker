ARG BASE_IMAGE_TAG=dev
ARG WORKER_TAG=0.1.10-alpha
FROM azure-functions/base:${BASE_IMAGE_TAG}

RUN mkdir PowerShellWorker && cd PowerShellWorker && \
    wget https://ci.appveyor.com/api/buildjobs/7lyurvik90a6h1y2/artifacts/package%2Fbin%2FRelease%2FMicrosoft.Azure.Functions.PowerShellWorker.0.1.10-alpha.nupkg -o Microsoft.Azure.Functions.PowerShellWorker.${WORKER_TAG}.tar.gz && \
    tar xvzf Microsoft.Azure.Functions.PowerShellWorker.${WORKER_TAG}.tar.gz && \
    mv ./contentFiles/any/any/workers/powershell ../azure-functions-host/workers/powershell
