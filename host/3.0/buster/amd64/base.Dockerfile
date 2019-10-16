FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS runtime-image

ENV PublishWithAspNetCoreTargetManifest=false
ENV HOST_VERSION=3.0.12785
ENV HOST_COMMIT=34e05fa6235394e98c0e73a1226d37f03cf9e97d

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    wget https://github.com/Azure/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers

FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.0

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image ["/workers", "/workers"]

RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.0.0/Microsoft.Azure.Functions.ExtensionBundle.1.0.0.zip && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.0.0 && \
    unzip /Microsoft.Azure.Functions.ExtensionBundle.1.0.0.zip -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.0.0 && \
    rm -f /Microsoft.Azure.Functions.ExtensionBundle.1.0.0.zip

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]
