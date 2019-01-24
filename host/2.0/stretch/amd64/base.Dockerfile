FROM microsoft/dotnet:2.2-sdk AS installer-env

ENV PublishWithAspNetCoreTargetManifest=false \
    HOST_VERSION=2.0.12285 \
    HOST_COMMIT=9b7c0fa24b604a9c840415247a97944967c78300

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    wget https://github.com/Azure/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers

FROM microsoft/dotnet:2.2-aspnetcore-runtime

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet

COPY --from=installer-env ["/azure-functions-host", "/azure-functions-host"]
COPY --from=installer-env ["/workers", "/workers"]

CMD [ "dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll" ]