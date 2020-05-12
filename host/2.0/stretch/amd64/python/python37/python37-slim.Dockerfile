# Build the runtime from source
ARG HOST_VERSION=2.0.13616
FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1/Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1 && \
    unzip /Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1 && \
    rm -f /Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip

# python37 image
FROM python:3.7-slim-stretch
ARG HOST_VERSION

ENV LANG=C.UTF-8 \
    ACCEPT_EULA=Y \
    AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=python \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates \
    libc6 libgcc1 libgssapi-krb5-2 libicu57 liblttng-ust0 libssl1.0.2 libstdc++6 zlib1g && \
    rm -rf /var/lib/apt/lists/*

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image [ "/workers/python", "/azure-functions-host/workers/python" ]
COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

ENV FUNCTIONS_WORKER_RUNTIME_VERSION=3.7

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]
