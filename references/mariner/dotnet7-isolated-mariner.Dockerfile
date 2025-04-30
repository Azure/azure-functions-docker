# Build the runtime from source
ARG HOST_VERSION
ARG VSS_NUGET_ACCESSTOKEN
ARG VSS_NUGET_URI_PREFIXES
ARG VSS_NUGET_EXTERNAL_FEED_ENDPOINTS

FROM mcr.microsoft.com/dotnet/sdk:8.0-cbl-mariner2.0 AS dn8-sdk-image
FROM mcr.microsoft.com/dotnet/sdk:6.0-cbl-mariner2.0 AS runtime-image
ARG HOST_VERSION
ARG VSS_NUGET_ACCESSTOKEN
ARG VSS_NUGET_URI_PREFIXES
ARG VSS_NUGET_EXTERNAL_FEED_ENDPOINTS="{\"endpointCredentials\": [{\"endpoint\":\"https://pkgs.dev.azure.com/msazure/one/_packaging/one_PublicPackages/nuget/v3/index.json\", \"username\":\"docker\", \"password\":\"${VSS_NUGET_ACCESSTOKEN}\"}]}"

# Download the artifact credential provider
RUN yum install -y dnf
RUN dnf install -y wget
RUN wget -qO- https://aka.ms/install-artifacts-credprovider.sh | bash

ENV PublishWithAspNetCoreTargetManifest=false

COPY --from=dn8-sdk-image [ "/usr/share/dotnet", "/usr/share/dotnet" ]

RUN BUILD_NUMBER=0 && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    if [ -n "$VSS_NUGET_ACCESSTOKEN" ]; then \
        sed -i.bak 's#<add key="nuget.org" value="[^\"]*"#<add key="one_PublicPackages" value="https://pkgs.dev.azure.com/msazure/one/_packaging/one_PublicPackages/nuget/v3/index.json"#' NuGet.config; \
    fi && \
    dotnet restore --verbosity detailed src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CI=true /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 --self-contained && \
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
    FUNCTIONS_WORKER_RUNTIME_VERSION=7.0 \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}.0 \
    ASPNETCORE_CONTENTROOT=/azure-functions-host \
    ASPNETCORE_URLS=http://+:80 \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing

# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
RUN dnf install -y glibc-devel

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=aspnet7 [ "/usr/share/dotnet", "/usr/share/dotnet" ]
COPY --from=dn8-sdk-image [ "/usr/share/dotnet", "/usr/share/dotnet" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]