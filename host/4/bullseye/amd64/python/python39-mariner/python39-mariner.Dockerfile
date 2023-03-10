
ARG HOST_VERSION=4.16.1

FROM mcr.microsoft.com/dotnet/sdk:6.0-cbl-mariner2.0 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src \;

RUN yum install -y dnf

RUN dnf install -y gnupg gnupg2 wget unzip && \
    EXTENSION_BUNDLE_VERSION_V2=2.21.0 && \
    EXTENSION_BUNDLE_FILENAME_V2=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V2}_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2/$EXTENSION_BUNDLE_FILENAME_V2 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V2 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V2 &&\
    find /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2/bin/runtimes/ -mindepth 1 -type d -not -name "linux-x64" -prune -exec rm -rf {} + && \
    EXTENSION_BUNDLE_VERSION_V3=3.19.0 && \
    EXTENSION_BUNDLE_FILENAME_V3=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V3}_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3/$EXTENSION_BUNDLE_FILENAME_V3 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V3 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V3 &&\
    find /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V3/bin/runtimes/ -mindepth 1 -type d -not -name "linux-x64" -prune -exec rm -rf {} + && \
    EXTENSION_BUNDLE_VERSION_V4=4.2.0 && \
    EXTENSION_BUNDLE_FILENAME_V4=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V4}_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4/$EXTENSION_BUNDLE_FILENAME_V4 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V4 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V4 &&\
    find /FuncExtensionBundles/ -type f -exec chmod 644 {} \;

#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM mcr.microsoft.com/cbl-mariner/base/python:3
ARG HOST_VERSION
RUN yum install -y dnf

ENV LANG=C.UTF-8 \
    ACCEPT_EULA=Y \
    AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=python \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host

# Install Python dependencies
RUN dnf install -y wget && \
    dnf install -y yum-utils curl gnupg2 gnupg && \
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    # # Needed for libss1.0.0 and in turn MS SQL
    curl https://packages.microsoft.com/config/rhel/9.0/prod.list > /etc/yum.repos.d/mssql-release.list && \
    # install necessary locales for MS SQL
    dnf install -y glibc-common && \
    echo 'LANG=en_US.utf8' > /etc/locale.conf && \
    # install MS SQL related packages
    dnf install -y unixODBC unixODBC-devel msodbcsql17 mssql-tools mssql-tools18 && \
    # .NET Core dependencies
    dnf install -y ca-certificates \
    glibc libgcc keyutils-libs krb5-libs libicu openssl-libs zlib && \
    # Custom dependencies:
    #  OpenCV dependencies:
    dnf install -y glib2 libSM libXext libXrender xorg-x11-server-Xvfb && \
    #  binutils
    dnf install -y binutils binutils-devel && \
    #  OpenMP dependencies
    dnf install -y libgomp libgomp-devel && \
    # mysql dependencies
    dnf install -y mysql-devel mysql && \
    #  Azure ML dependencies
    dnf install -y lttng-ust
    # Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
    #apt-get install -y libc-dev && \

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image [ "/workers/python/3.9/LINUX", "/azure-functions-host/workers/python/3.9/LINUX" ]
COPY --from=runtime-image [ "/workers/python/worker.config.json", "/azure-functions-host/workers/python" ]
COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

ENV FUNCTIONS_WORKER_RUNTIME_VERSION=3.9

EXPOSE 2222 80

# python3 symlink
RUN ln -s /usr/bin/python3 /usr/bin/python


RUN dnf install -y openssh-server dialog && \
    ssh-keygen -A && \
    echo "root:Docker!" | chpasswd && \
    pip install ptvsd


COPY sshd_config /etc/ssh/
COPY start.sh /azure-functions-host/

RUN chmod +x /azure-functions-host/start.sh

ENTRYPOINT ["/azure-functions-host/start.sh"]
