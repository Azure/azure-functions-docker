ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/python:2.0

FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS installer-env

ENV PublishWithAspNetCoreTargetManifest=false \
    HOST_VERSION=2.0.12409 \
    HOST_COMMIT=c545cbf56b8410b054ca058219e62f8ace697b74

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    wget https://github.com/Azure/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --runtime debian.9-x64 --output /azure-functions-host

FROM ${BASE_IMAGE}

ENV ASPNETCORE_VERSION=2.2.3 \
    FUNCTIONS_WORKER_RUNTIME=

# Install node
RUN mv /azure-functions-host/workers/python /python && \
    rm -rf /azure-functions-host && \
    apt-get update && \
    apt-get install -y gnupg wget unzip curl && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    mkdir -p /azure-functions-host/workers && \
    mv /python /azure-functions-host/workers && \
    # .NET Core for powershell
    curl -SL --output aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-x64.tar.gz \
    && aspnetcore_sha512='53be8489aafa132c1a7824339c9a0d25f33e6ab0c42f414a8bda014b60ff82a20144032bd7e887d375dc275bb5dbeb71d38c7f90c39016895df8d3cf3c4b7a95' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Add all workers
COPY --from=installer-env ["/azure-functions-host", "/azure-functions-host"]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]