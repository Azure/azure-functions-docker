FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS runtime-image

ENV PublishWithAspNetCoreTargetManifest=false
ENV HOST_VERSION=3.0.13054
ENV HOST_COMMIT=ddc8539aa9f8523aa8a2e887b040d2c05d346ca7

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    wget https://github.com/Azure/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers

FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.1

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image ["/workers", "/workers"]

RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1/Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1 && \
    unzip /Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.1 && \
    rm -f /Microsoft.Azure.Functions.ExtensionBundle.1.1.1.zip

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]
