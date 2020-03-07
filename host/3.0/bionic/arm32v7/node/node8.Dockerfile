# Build the runtime from source
ARG HOST_VERSION=3.0.13142
FROM mcr.microsoft.com/azure-functions/base:grpc-1.20-arm32v7 as grpc-image
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false
RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers
RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1/Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1 && \
    unzip /Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1 && \
    rm -f /Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip
RUN apt-get update && \
    apt-get install -y qemu-user qemu-user-static

# build node native binaries
FROM arm32v7/node:8-stretch AS grpc-node-image

COPY --from=runtime-image ["/usr/bin/qemu-arm-static", "/usr/bin"]

RUN apt-get update && \
    apt-get install -y build-essential && \
    mkdir /node-grpc && \
    cd node-grpc && \
    npm install grpc@1.18.0

# runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-bionic-arm32v7
ARG HOST_VERSION

COPY --from=runtime-image ["/usr/bin/qemu-arm-static", "/usr/bin"]
COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image ["/workers/node", "/azure-functions-host/workers/node"]
COPY --from=runtime-image ["/FuncExtensionBundles", "/FuncExtensionBundles"]
COPY --from=grpc-image ["/libgrpc_csharp_ext.so.1.20.1", "/"]
COPY --from=grpc-node-image ["/node-grpc/node_modules/grpc/src/node/extension_binary/node-v57-linux-arm-glibc/grpc_node.node", "/grpc_node.node"]

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    mkdir -p /azure-functions-host/workers/node/grpc/src/node/extension_binary/node-v57-linux-arm-glibc && \
    mv /grpc_node.node /azure-functions-host/workers/node/grpc/src/node/extension_binary/node-v57-linux-arm-glibc/

RUN rm -f /azure-functions-host/runtimes/linux/native/* && \
    mv libgrpc_csharp_ext.so.1.20.1 /azure-functions-host/runtimes/linux/native/ && \
    cd /azure-functions-host/runtimes/linux/native/ && \
    ln -s libgrpc_csharp_ext.so.1.20.1 libgrpc_csharp_ext.so && \
    ln -s libgrpc_csharp_ext.so.1.20.1 libgrpc_csharp_ext.x64.so && \
    ln -s libgrpc_csharp_ext.so.1.20.1 libgrpc_csharp_ext.x86.so && \
    ln -s libgrpc_csharp_ext.so.1.20.1 libgrpc_csharp_ext.arm32v7.so

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=node \
    DOTNET_USE_POLLING_FILE_WATCHER=false \
    HOST_VERSION=${HOST_VERSION}

RUN rm /usr/bin/qemu-arm-static

CMD ["dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll"]
