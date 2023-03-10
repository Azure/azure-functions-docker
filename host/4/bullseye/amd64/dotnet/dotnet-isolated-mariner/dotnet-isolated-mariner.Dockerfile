
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

RUN yum install -y dnf && \
    dnf install -y gnupg wget unzip && \
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

# Include ASP.NET Core shared framework from dotnet/aspnet image.
# FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS aspnet6

FROM mcr.microsoft.com/dotnet/sdk:6.0-cbl-mariner2.0
ARG HOST_VERSION

RUN yum install -y dnf

COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]
COPY sshd_config /etc/ssh/
COPY start.sh /azure-functions-host/
COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host

# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
RUN dnf install -y glibc-devel

# For debugging
RUN dnf install -y procps net-tools which

# COPY --from=aspnet6 [ "/usr/share/dotnet", "/usr/share/dotnet" ]

EXPOSE 2222 80

RUN dnf install -y awk initscripts

RUN ssh-keygen -A && \
    dnf install -y gnupg wget unzip curl dialog openssh-server && \
    # Add remote dotnet debugger
    curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v vs2017u5 -l /root/vsdbg && \
    echo "root:Docker!" | chpasswd


RUN chmod +x /azure-functions-host/start.sh

ENTRYPOINT ["/azure-functions-host/start.sh"]
