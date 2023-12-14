# Build the runtime from source
ARG HOST_VERSION=4.28.3
FROM mcr.microsoft.com/dotnet/sdk:6.0-cbl-mariner2.0 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

# Include ASP.NET Core shared framework from dotnet/aspnet image.
FROM mcr.microsoft.com/dotnet/aspnet:7.0-cbl-mariner2.0 AS aspnet7

FROM mcr.microsoft.com/dotnet/runtime:7.0-cbl-mariner2.0
ARG HOST_VERSION

RUN yum install -y dnf

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing

# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
RUN dnf install -y glibc-devel

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=aspnet7 [ "/usr/share/dotnet", "/usr/share/dotnet" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]