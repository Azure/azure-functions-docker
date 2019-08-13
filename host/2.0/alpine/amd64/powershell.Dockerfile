FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS runtime-image

ENV PublishWithAspNetCoreTargetManifest=false \
    HOST_VERSION=2.0.12625 \
    HOST_COMMIT=58f5a4a1133357a41f9d5810ee1cf105b9c68363

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    # apk add --no-cache wget tar && \
    wget https://github.com/Azure/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /workers/powershell/runtimes/win* && \
    rm -rf /workers/powershell/runtimes/osx && \
    rm -rf /workers/powershell/runtimes/*arm*

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-alpine

RUN apk add --no-cache libc6-compat libnsl && \
    # workaround for https://github.com/grpc/grpc/issues/17255
    ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=powershell

RUN apk update && \
    apk add --no-cache gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.0.0/Microsoft.Azure.Functions.ExtensionBundle.1.0.0.zip && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.0.0 && \
    unzip /Microsoft.Azure.Functions.ExtensionBundle.1.0.0.zip -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.0.0 && \
    rm -f /Microsoft.Azure.Functions.ExtensionBundle.1.0.0.zip

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image [ "/workers/powershell", "/azure-functions-host/workers/powershell" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]