# Build the runtime from source
ARG HOST_VERSION=2.0.14192
FROM mcr.microsoft.com/azure-functions/base:grpc-2.27-arm32v7 as grpc-image
FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src

RUN EXTENSION_BUNDLE_VERSION=1.3.2 && \
    EXTENSION_BUNDLE_FILENAME=Microsoft.Azure.Functions.ExtensionBundle.1.3.2_linux-x64.zip && \
    apt-get update && \
    apt-get install -y gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION/$EXTENSION_BUNDLE_FILENAME && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION && \
    unzip /$EXTENSION_BUNDLE_FILENAME -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION && \
    rm -f /$EXTENSION_BUNDLE_FILENAME && \
    EXTENSION_BUNDLE_VERSION_V2=2.0.0 && \
    EXTENSION_BUNDLE_FILENAME_V2=Microsoft.Azure.Functions.ExtensionBundle.2.0.0_linux-x64.zip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2/$EXTENSION_BUNDLE_FILENAME_V2 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V2 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V2 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V2 &&\
    find /FuncExtensionBundles/ -type f -exec chmod 644 {} \;

RUN apt-get update && \
    apt-get install -y qemu-user qemu-user-static

# Runtime image
# Simulate mcr.microsoft.com/dotnet/core/aspnet:2.2-bionic-arm32v7 based on https://github.com/dotnet/dotnet-docker/blob/master/src/aspnet/2.1/bionic/arm32v7/Dockerfile
# Workaround to get the patched 2.1 deps and asp.net v2.2
FROM mcr.microsoft.com/dotnet/core/runtime-deps:2.1-bionic-arm32v7
ARG HOST_VERSION

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install ASP.NET Core
ENV ASPNETCORE_VERSION 2.2.8

RUN curl -SL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-arm.tar.gz \
    && aspnetcore_sha512='fab9a1d9d101716337bb153af2ac36429fc387230c0c0bf2d639b31fb7f787bc8dbaaa31f28f9cbe69f117ffc78d8ddb5a5968da0e77785d3c12c6814ef50f7b' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

COPY --from=runtime-image ["/usr/bin/qemu-arm-static", "/usr/bin"]
COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image ["/FuncExtensionBundles", "/FuncExtensionBundles"]
COPY --from=grpc-image ["/libgrpc_csharp_ext.so.2.27.3", "/"]

RUN rm -f /azure-functions-host/runtimes/linux/native/* && \
    mv libgrpc_csharp_ext.so.2.27.3 /azure-functions-host/runtimes/linux/native/ && \
    cd /azure-functions-host/runtimes/linux/native/ && \
    ln -s libgrpc_csharp_ext.so.2.27.3 libgrpc_csharp_ext.so && \
    ln -s libgrpc_csharp_ext.so.2.27.3 libgrpc_csharp_ext.x64.so && \
    ln -s libgrpc_csharp_ext.so.2.27.3 libgrpc_csharp_ext.x86.so && \
    ln -s libgrpc_csharp_ext.so.2.27.3 libgrpc_csharp_ext.arm32v7.so

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet \
    DOTNET_USE_POLLING_FILE_WATCHER=false \
    HOST_VERSION=${HOST_VERSION}

RUN rm /usr/bin/qemu-arm-static

CMD ["dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll"]
