ARG JAVA_VERSION=8u252

ARG HOST_VERSION=3.2.0

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false
ENV DEBIAN_FRONTEND=noninteractive

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host.git /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

RUN EXTENSION_BUNDLE_VERSION=1.8.1 && \
    EXTENSION_BUNDLE_FILENAME=Microsoft.Azure.Functions.ExtensionBundle.1.8.1_linux-x64.zip && \
    apt-get update && \
    apt-get install -y gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION/$EXTENSION_BUNDLE_FILENAME && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION && \
    unzip /$EXTENSION_BUNDLE_FILENAME -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION && \
    rm -f /$EXTENSION_BUNDLE_FILENAME && \
    EXTENSION_BUNDLE_VERSION_V2=2.6.1 && \
    EXTENSION_BUNDLE_FILENAME_V2=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V2}_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2/$EXTENSION_BUNDLE_FILENAME_V2 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V2 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V2 &&\
    EXTENSION_BUNDLE_VERSION_V3=3.0.0 && \
    EXTENSION_BUNDLE_FILENAME_V3=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V3}_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3/$EXTENSION_BUNDLE_FILENAME_V3 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V3 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V3 &&\
    find /FuncExtensionBundles/ -type f -exec chmod 644 {} \;

ARG JAVA_VERSION=8u252
FROM mcr.microsoft.com/java/jre-headless:${JAVA_VERSION}-zulu-debian10-with-tools as jre
FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.1
ARG HOST_VERSION

EXPOSE 2222 80

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=java \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=runtime-image [ "/workers/java", "/azure-functions-host/workers/java" ]
COPY --from=jre [ "/usr/lib/jvm/zre-hl-8-azure-amd64", "/usr/lib/jvm/zre-8-azure-amd64" ]

## Using this method with ../ requires the docker build be run from the /out/ folder.
## Alternative solution would be to copy the main files for sshd and start.sh to each lang folder
COPY sshd_config /etc/ssh/
COPY start.sh /azure-functions-host/
COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

ENV JAVA_HOME /usr/lib/jvm/zre-8-azure-amd64

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server dialog && \
    echo "root:Docker!" | chpasswd

RUN chmod +x /azure-functions-host/start.sh

ENTRYPOINT ["/azure-functions-host/start.sh"]