ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/python:2.0

FROM microsoft/dotnet:2.2-sdk AS installer-env

ENV PublishWithAspNetCoreTargetManifest=false \
    HOST_VERSION=2.0.12276 \
    HOST_COMMIT=1c0920e4a3709e333aa71338fcec62a80bb6b4f7

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    wget https://github.com/Azure/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --runtime debian.9-x64 --output /azure-functions-host

FROM ${BASE_IMAGE}

ENV FUNCTIONS_WORKER_RUNTIME=

# Install node
RUN mv /azure-functions-host/workers/python /python && \
    rm -rf /azure-functions-host && \
    apt-get update && \
    apt-get install -y gnupg wget unzip curl && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs

# Add all workers
COPY --from=installer-env ["/azure-functions-host", "/azure-functions-host"]
RUN mv /python /azure-functions-host/workers/

CMD [ "dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll" ]