FROM microsoft/dotnet:2.2-sdk AS installer-env

ENV PublishWithAspNetCoreTargetManifest=false \
    HOST_VERSION=2.0.12332 \
    HOST_COMMIT=287a2708f3f164e303bd371049101cfa48d1766b

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    # apk add --no-cache wget tar && \
    wget https://github.com/Azure/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers

FROM microsoft/dotnet:2.2-aspnetcore-runtime-alpine

RUN apk add --no-cache libc6-compat libnsl && \
    # workaround for https://github.com/grpc/grpc/issues/17255
    ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet

COPY --from=installer-env ["/azure-functions-host", "/azure-functions-host"]
COPY --from=installer-env ["/workers", "/workers"]

CMD [ "dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll" ]