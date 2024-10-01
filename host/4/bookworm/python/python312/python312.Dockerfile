#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Build the runtime from source
ARG HOST_VERSION=4.1036.2
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim-amd64 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 --self-contained && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    EXTENSION_BUNDLE_VERSION_V4=4.20.0 && \
    EXTENSION_BUNDLE_FILENAME_V4=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V4}_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4/$EXTENSION_BUNDLE_FILENAME_V4 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V4 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V4 &&\
    find /FuncExtensionBundles/ -type f -exec chmod 644 {} \;

FROM mcr.microsoft.com/oryx/python:3.12-debian-bookworm AS python
FROM mcr.microsoft.com/dotnet/aspnet:8.0-bookworm-slim-amd64
ARG HOST_VERSION

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]
COPY install_ca_certificates.sh start_nonappservice.sh /opt/startup/
RUN chmod +x /opt/startup/install_ca_certificates.sh && \
    chmod +x /opt/startup/start_nonappservice.sh

# Install Python dependencies
RUN apt-get update && \
    apt-get install -y wget apt-transport-https curl gnupg2 locales && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo "deb [arch=amd64] https://packages.microsoft.com/debian/12/prod bookworm main" | tee /etc/apt/sources.list.d/mssql-release.list && \
    # Needed for libss3 and in turn MS SQL
    echo 'deb http://security.debian.org/debian-security bookworm-security main' >> /etc/apt/sources.list && \
    curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
    # install MS SQL related packages.pinned version in PR # 1012.
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    apt-get update && \
    # MS SQL related packages: unixodbc msodbcsql18 mssql-tools
    ACCEPT_EULA=Y apt-get install -y unixodbc msodbcsql18 mssql-tools18 && \
    # OpenCV dependencies:libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb
    apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb && \
    # .NET Core dependencies: ca-certificates libc6 libgcc1 libgssapi-krb5-2 libicu72 libssl3 libstdc++6 zlib1g 
    # Azure ML dependencies: liblttng-ust0
    # OpenMP dependencies: libgomp1
    # binutils: binutils
    apt-get install -y --no-install-recommends ca-certificates \
    libc6 libgcc1 libgssapi-krb5-2 libicu72 libssl3 libstdc++6 zlib1g && \
    apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb binutils \
    libgomp1 liblttng-ust1 && \
    rm -rf /var/lib/apt/lists/* 

COPY --from=runtime-image [ "/workers/python/3.12/LINUX", "/azure-functions-host/workers/python/3.12/LINUX" ]
COPY --from=runtime-image [ "/workers/python/worker.config.json", "/azure-functions-host/workers/python" ]
COPY --from=python [ "/opt", "/opt" ]

# Link all binaries from /opt/python/3.12/bin to /usr/bin/
RUN for file in /opt/python/3.12/bin/*; do \
        ln -sf "$file" /usr/bin/$(basename "$file"); \
    done

ENV LANG=C.UTF-8 \
    ACCEPT_EULA=Y \ 
    AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=python \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host \
    LD_LIBRARY_PATH=/opt/python/3.12/lib:$LD_LIBRARY_PATH \
    FUNCTIONS_WORKER_RUNTIME_VERSION=3.12 

CMD [ "/opt/startup/start_nonappservice.sh" ]
