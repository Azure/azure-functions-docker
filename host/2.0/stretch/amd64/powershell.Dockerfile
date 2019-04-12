FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS runtime-image

ENV PublishWithAspNetCoreTargetManifest=false \
    HOST_VERSION=2.0.12408 \
    HOST_COMMIT=0a4498b8d8014169c5ed66c7cded65dc708498e4

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    wget https://github.com/Azure/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /workers/powershell/runtimes/win* && \
    rm -rf /workers/powershell/runtimes/osx && \
    rm -rf /workers/powershell/runtimes/*arm*

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=powershell

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image [ "/workers/powershell", "/azure-functions-host/workers/powershell" ]

CMD [ "dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll" ]