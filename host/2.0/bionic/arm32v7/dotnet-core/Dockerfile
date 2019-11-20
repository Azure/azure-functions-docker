
ARG HOST_TAG=2.0.12835
FROM mcr.microsoft.com/dotnet/core/sdk:2.2 as host-build-env
ARG HOST_TAG

ENV PublishWithAspNetCoreTargetManifest false

# Install Runtime
RUN BUILD_NUMBER=$(echo ${HOST_TAG} | cut -d'.' -f 3 | cut -d'-' -f 1) && \
    wget https://github.com/Azure/azure-functions-host/archive/${HOST_TAG}.tar.gz && \
    tar xvzf ${HOST_TAG}.tar.gz && \
    cd azure-functions-host-* && \
    dotnet build /p:BuildNumber="$BUILD_NUMBER" WebJobs.Script.sln && \
    dotnet publish /p:BuildNumber="$BUILD_NUMBER" src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-bionic-arm32v7
ARG HOST_TAG

COPY --from=host-build-env ["/azure-functions-host", "/azure-functions-host"]

COPY ["libgrpc_csharp_ext.so", "/azure-functions-host/libgrpc_csharp_ext.so"]
COPY ["libgrpc_csharp_ext.so", "/azure-functions-host/libgrpc_csharp_ext.x86.so"]

COPY ./qemu-arm-static /usr/bin/

RUN mkdir -p /home/site/wwwroot

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    ASPNETCORE_URLS=http://+:80

RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.0/Microsoft.Azure.Functions.ExtensionBundle.1.1.0.zip && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.0 && \
    unzip /Microsoft.Azure.Functions.ExtensionBundle.1.1.0.zip -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.1.0 && \
    rm -f /Microsoft.Azure.Functions.ExtensionBundle.1.1.0.zip && \
    rm -f /usr/bin/qemu-arm-static

EXPOSE 80

CMD ["dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll"]
