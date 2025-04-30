ARG HOST_VERSION
ARG EXTENSION_BUNDLE_VERSION_V2
ARG EXTENSION_BUNDLE_VERSION_V3
ARG EXTENSION_BUNDLE_VERSION_V4
ARG VSS_NUGET_ACCESSTOKEN
ARG VSS_NUGET_URI_PREFIXES
ARG VSS_NUGET_EXTERNAL_FEED_ENDPOINTS
ARG DOCKER_REVISION
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim-amd64 AS host-builder-dotnet10
ARG HOST_VERSION
ARG EXTENSION_BUNDLE_VERSION_V2
ARG EXTENSION_BUNDLE_VERSION_V3
ARG EXTENSION_BUNDLE_VERSION_V4
ARG VSS_NUGET_ACCESSTOKEN
ARG VSS_NUGET_URI_PREFIXES
ARG VSS_NUGET_EXTERNAL_FEED_ENDPOINTS="{\"endpointCredentials\": [{\"endpoint\":\"https://pkgs.dev.azure.com/msazure/one/_packaging/one_PublicPackages/nuget/v3/index.json\", \"username\":\"docker\", \"password\":\"${VSS_NUGET_ACCESSTOKEN}\"}]}"
ARG DOCKER_REVISION

# Download the artifact credential provider
RUN wget -qO- https://aka.ms/install-artifacts-credprovider.sh | bash

ENV PublishWithAspNetCoreTargetManifest=false
ENV DEBIAN_FRONTEND=noninteractive

RUN wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0

RUN BUILD_NUMBER=${DOCKER_REVISION} && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    if [ -n "$VSS_NUGET_ACCESSTOKEN" ]; then \
        sed -i.bak 's#<add key="nuget.org" value="[^\"]*"#<add key="one_PublicPackages" value="https://pkgs.dev.azure.com/msazure/one/_packaging/one_PublicPackages/nuget/v3/index.json"#' NuGet.config; \
    fi && \
    dotnet restore --verbosity detailed src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CI=true /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --self-contained --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    EXTENSION_BUNDLE_VERSION_V4=${EXTENSION_BUNDLE_VERSION_V4} && \
    EXTENSION_BUNDLE_FILENAME_V4=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V4}_linux-x64.zip && \
    wget https://cdn.functions.azure.com/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4/$EXTENSION_BUNDLE_FILENAME_V4 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V4 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V4 &&\
    find /FuncExtensionBundles/ -type f -exec chmod 644 {} \;

FROM scratch as linuxtrixie-workers
COPY --from=host-builder-dotnet10 ["/workers", "/workers"]

FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview-trixie-slim-amd64 AS linuxtrixie-base
ARG HOST_VERSION
ARG DOCKER_REVISION

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}.${DOCKER_REVISION}

COPY --from=host-builder-dotnet10 [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=host-builder-dotnet10 [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]
# Copy CA certs for TLS ECC Root explicitly. They may be automatically added by the OS in future.
COPY /ca_certificates/* /usr/local/share/ca-certificates/
RUN update-ca-certificates

COPY components/install_ca_certificates.sh components/start_nonappservice.sh /opt/startup/

# Dotnet 8 Containers start with a default app. We only need to update default shell
RUN usermod -s /bin/bash app && \
mkdir -p /home/site/wwwroot && \
mkdir -p /local/sitepackages && \
mkdir -p /tmp/metrics && \
chown -R app:app /home && \
chown -R app:app /local && \
chown -R app:app /tmp/metrics

RUN mkdir /azure-functions-host/Secrets && \
 chown -R app:app /azure-functions-host/Secrets && \
 chmod -R 777 /azure-functions-host/Secrets

RUN apt-get update && \
    chmod +x /opt/startup/install_ca_certificates.sh && \
    chmod +x /opt/startup/start_nonappservice.sh