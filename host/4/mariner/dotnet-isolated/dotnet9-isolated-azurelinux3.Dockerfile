# Build the runtime from source
ARG HOST_VERSION=4.1037.1
FROM mcr.microsoft.com/dotnet/sdk:8.0-azurelinux3.0 AS sdk-image
ARG HOST_VERSION
ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 --self-contained && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

# Include ASP.NET Core shared framework from dotnet/aspnet image.
FROM mcr.microsoft.com/dotnet/aspnet:9.0-azurelinux3.0 AS aspnet9

FROM mcr.microsoft.com/dotnet/runtime:9.0-azurelinux3.0
ARG HOST_VERSION

RUN curl -O https://packages.microsoft.com/azurelinux/3.0/prod/base/x86_64/Packages/g/glibc-devel-2.38-8.azl3.x86_64.rpm
RUN tdnf install -y glibc-devel-2.38-8.azl3.x86_64.rpm

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    ASPNETCORE_URLS=http://+:80

COPY --from=sdk-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=aspnet9 [ "/usr/share/dotnet", "/usr/share/dotnet" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]