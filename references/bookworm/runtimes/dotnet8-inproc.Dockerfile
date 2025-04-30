# Build the runtime from source
ARG HOST_BASE_IMAGE
ARG INPROC_HOST_VERSION
ARG DOCKER_REVISION
ARG VSS_NUGET_ACCESSTOKEN
ARG VSS_NUGET_URI_PREFIXES
ARG VSS_NUGET_EXTERNAL_FEED_ENDPOINTS

FROM ${HOST_BASE_IMAGE} AS base
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim-amd64 AS host-builder
ARG INPROC_HOST_VERSION
ARG DOCKER_REVISION
ARG VSS_NUGET_ACCESSTOKEN
ARG VSS_NUGET_URI_PREFIXES
ARG VSS_NUGET_EXTERNAL_FEED_ENDPOINTS="{\"endpointCredentials\": [{\"endpoint\":\"https://pkgs.dev.azure.com/msazure/one/_packaging/one_PublicPackages/nuget/v3/index.json\", \"username\":\"docker\", \"password\":\"${VSS_NUGET_ACCESSTOKEN}\"}]}"

# Download the artifact credential provider
RUN wget -qO- https://aka.ms/install-artifacts-credprovider.sh | bash

ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=${DOCKER_REVISION} && \
    git clone --branch v${INPROC_HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    if [ -n "$VSS_NUGET_ACCESSTOKEN" ]; then \
        sed -i.bak 's#<add key="nuget.org" value="[^\"]*"#<add key="one_PublicPackages" value="https://pkgs.dev.azure.com/msazure/one/_packaging/one_PublicPackages/nuget/v3/index.json"#' NuGet.config; \
    fi && \
    dotnet restore --verbosity detailed src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CI=true /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 --framework net8.0 --self-contained /p:MinorVersionPrefix=8 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-bookworm-slim-amd64 AS linuxdedicatedbookworm-runtime
ARG DOCKER_REVISION
ARG INPROC_HOST_VERSION

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${INPROC_HOST_VERSION}.${DOCKER_REVISION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host \
    ASPNETCORE_URLS=http://+:80

COPY --from=host-builder [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=base /opt/startup/install_ca_certificates.sh /opt/startup/
COPY --from=base /opt/startup/start_nonappservice.sh /opt/startup/
# Copy CA certs for TLS ECC Root explicitly. They may be automatically added by the OS in future.
COPY --from=base /usr/local/share/ca-certificates/* /usr/local/share/ca-certificates/
RUN update-ca-certificates

RUN chmod +x /opt/startup/install_ca_certificates.sh && \
    chmod +x /opt/startup/start_nonappservice.sh

CMD [ "/opt/startup/start_nonappservice.sh" ]