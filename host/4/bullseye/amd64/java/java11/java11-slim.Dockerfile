# Build the runtime from source
ARG HOST_VERSION=4.34.1
ARG JAVA_VERSION=11.0.21
ARG JAVA_HOME=/usr/lib/jvm/msft-11-x64
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS runtime-image
ARG HOST_VERSION
ARG JAVA_VERSION
ARG JAVA_HOME

ENV PublishWithAspNetCoreTargetManifest=false
ENV DEBIAN_FRONTEND=noninteractive

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    EXTENSION_BUNDLE_VERSION_V2=2.33.1 && \
    EXTENSION_BUNDLE_FILENAME_V2=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V2}_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2/$EXTENSION_BUNDLE_FILENAME_V2 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V2 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V2 &&\
    EXTENSION_BUNDLE_VERSION_V3=3.33.0 && \
    EXTENSION_BUNDLE_FILENAME_V3=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V3}_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3/$EXTENSION_BUNDLE_FILENAME_V3 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V3 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V3 &&\
    EXTENSION_BUNDLE_VERSION_V4=4.17.0 && \
    EXTENSION_BUNDLE_FILENAME_V4=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V4}_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4/$EXTENSION_BUNDLE_FILENAME_V4 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V4 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V4 &&\
    find /FuncExtensionBundles/ -type f -exec chmod 644 {} \;

RUN wget https://aka.ms/download-jdk/microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz && \
    mkdir -p ${JAVA_HOME} && \
    tar -xzf microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz -C ${JAVA_HOME} --strip-components=1 && \
    rm -f microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz

FROM mcr.microsoft.com/dotnet/runtime-deps:6.0
ARG HOST_VERSION
ARG JAVA_HOME

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=java \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host \
    JAVA_HOME=${JAVA_HOME}

# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
RUN apt-get update && \
    apt-get install -y libc-dev 

# Fix from https://github.com/AdoptOpenJDK/blog/blob/ba5844ddc0b7e25d8ae49ac65a8b4e25dea5a48c/content/blog/prerequisites-for-font-support-in-adoptopenjdk/index.md#linux
RUN apt-get update && \
    apt-get install -y libfreetype6 fontconfig fonts-dejavu

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=runtime-image [ "/workers/java", "/azure-functions-host/workers/java" ]
COPY --from=runtime-image [ "${JAVA_HOME}", "${JAVA_HOME}" ]
COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]
COPY install_ca_certificates.sh start_nonappservice.sh /opt/startup/
RUN chmod +x /opt/startup/install_ca_certificates.sh && \
    chmod +x /opt/startup/start_nonappservice.sh


CMD [ "/opt/startup/start_nonappservice.sh" ]
