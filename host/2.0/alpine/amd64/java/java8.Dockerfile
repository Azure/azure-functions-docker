# Build the runtime from source
ARG HOST_VERSION=2.0.13616
FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host --runtime linux-musl-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1/Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1 && \
    unzip /Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1 && \
    rm -f /Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zi

FROM openjdk:8-jdk-alpine as jdk
RUN mkdir -p /usr/lib/jvm/java-1.8-openjdk

# runtime image
FROM mcr.microsoft.com/dotnet/core/runtime-deps:2.2-alpine3.8
ARG HOST_VERSION

RUN apk update && apk add --no-cache libc6-compat

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=java \
    DOTNET_USE_POLLING_FILE_WATCHER=false \
    HOST_VERSION=${HOST_VERSION} \
    JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=runtime-image [ "/workers/java", "/azure-functions-host/workers/java" ]
COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]
COPY --from=jdk ["/usr/lib/jvm/java-1.8-openjdk", "/usr/lib/jvm/java-1.8-openjdk"]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]
