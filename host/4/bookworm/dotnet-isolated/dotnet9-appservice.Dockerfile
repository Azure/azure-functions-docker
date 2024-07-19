# Build the runtime from source
ARG HOST_VERSION=4.1035.1
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim-amd64 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:NugetAudit=false /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 --framework net8.0 --self-contained /p:MinorVersionPrefix=8 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

FROM mcr.microsoft.com/dotnet/aspnet:9.0-preview-bookworm-slim-amd64
ARG HOST_VERSION

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    ASPNETCORE_URLS=http://+:80

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY sshd_config /etc/ssh/
COPY start.sh /azure-functions-host/
COPY install_ca_certificates.sh /opt/startup/

EXPOSE 2222 80

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server dialog && \
    echo "root:Docker!" | chpasswd && \
    chmod +x /azure-functions-host/start.sh && \
    chmod +x /opt/startup/install_ca_certificates.sh

ENTRYPOINT ["/azure-functions-host/start.sh"]