
ARG HOST_TAG=v2.0.11888-alpha
FROM microsoft/dotnet:2.1-sdk as host-build-env
ARG HOST_TAG

ENV PublishWithAspNetCoreTargetManifest false

# Install Runtime
RUN BUILD_NUMBER=$(echo ${HOST_TAG} | cut -d'.' -f 3 | cut -d'-' -f 1) && \
    wget https://github.com/Azure/azure-functions-host/archive/${HOST_TAG}.tar.gz && \
    tar xvzf ${HOST_TAG}.tar.gz && \
    cd azure-functions-host-* && \
    dotnet build /p:BuildNumber="$BUILD_NUMBER" WebJobs.Script.sln && \
    dotnet publish /p:BuildNumber="$BUILD_NUMBER" src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --runtime linux-arm --output /azure-functions-host

FROM resin/rpi-raspbian:stretch
ARG HOST_TAG

COPY --from=host-build-env ["/azure-functions-host", "/azure-functions-host"]

# Install python worker
RUN [ "cross-build-start" ]

# Install .NET Deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    libc6 \
    libcurl3 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu57 \
    liblttng-ust0 \
    libssl1.0.2 \
    libstdc++6 \
    libunwind8 \
    libuuid1 \
    zlib1g && \
    rm -rf /var/lib/apt/lists/*
# End Install .NET Deps

COPY ["libgrpc_csharp_ext.so", "/azure-functions-host/libgrpc_csharp_ext.so"]
COPY ["libgrpc_csharp_ext.so", "/azure-functions-host/libgrpc_csharp_ext.x86.so"]

RUN mkdir -p /home/site/wwwroot

ENV AzureWebJobsScriptRoot=/home/site/wwwroot


ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
RUN [ "cross-build-end" ]

CMD ["/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost"]
