# Build the runtime from source
ARG HOST_VERSION=4.0.0-preview.1.15799
FROM mcr.microsoft.com/dotnet/nightly/sdk:6.0.100-preview.4 AS runtime-image
ARG HOST_VERSION

# Build requires 3.1 SDK
COPY --from=mcr.microsoft.com/dotnet/core/sdk:3.1 /usr/share/dotnet /usr/share/dotnet

ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 5) && \
    BRANCH_NAME=release/$(echo ${HOST_VERSION} | cut -d'.' -f 1-4) && \
    SUFFIX=$(echo ${HOST_VERSION} | cut -d'-' -f 2 | cut -d'.' -f 1-2) && \
    git clone --branch $BRANCH_NAME https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:VersionSuffix=$SUFFIX /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

FROM mcr.microsoft.com/dotnet/nightly/runtime-deps:6.0.0-preview.4
ARG HOST_VERSION

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}

# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
RUN apt-get update && \
    apt-get install -y libc-dev

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]