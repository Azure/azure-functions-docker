# Build the runtime from source
ARG HOST_VERSION=3.0.14358
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest false

# Build WebJobs.Script.WebHost from source
RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

# Install additional tools needed
RUN apt-get update && \
    apt-get install -y gnupg wget unzip jq

# Install just bundle version 2
RUN EXTENSION_BUNDLE_VERSION_V2=2.0.1 && \
    EXTENSION_BUNDLE_FILENAME_V2=Microsoft.Azure.Functions.ExtensionBundle.2.0.1_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2/$EXTENSION_BUNDLE_FILENAME_V2 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V2 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V2

# Set the powershell worker supported versions and default to 7 (as dotnet core 2 is no longer included in image)
RUN PWSH_WORKER_CONFIG=/workers/powershell/worker.config.json && \
    TEMP=$(mktemp) && \
    echo $TEMP && \
    jq '.description.supportedRuntimeVersions = ["7"]' $PWSH_WORKER_CONFIG \
    | jq '.description.defaultRuntimeVersion = "7"' \
    > "$TEMP" && mv "$TEMP" $PWSH_WORKER_CONFIG

RUN find /FuncExtensionBundles/ -type f -exec chmod 644 {} \;

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim
ARG HOST_VERSION

# set runtime env variables
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=powershell \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}

# copy bundles, host runtime and powershell worker from the build image
COPY --from=runtime-image ["/FuncExtensionBundles", "/FuncExtensionBundles"]
COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image ["/workers/powershell", "/azure-functions-host/workers/powershell"]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]
