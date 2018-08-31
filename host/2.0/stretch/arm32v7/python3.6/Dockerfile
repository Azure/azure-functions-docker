ARG HOST_TAG=v2.0.11776-alpha
ARG WORKER_TAG=1.0.0a4
FROM microsoft/dotnet:2.0-sdk-stretch as host-build-env
ARG HOST_TAG
ARG WORKER_TAG

ENV PublishWithAspNetCoreTargetManifest false

# Install Runtime
RUN BUILD_NUMBER=$(echo ${HOST_TAG} | cut -d'.' -f 3 | cut -d'-' -f 1) && \
    wget https://github.com/Azure/azure-functions-host/archive/6508d0044156e18f0c608357828d793e52121fc9.tar.gz && \
    tar xvzf 6508d0044156e18f0c608357828d793e52121fc9.tar.gz && \
    cd azure-functions-host-* && \
    dotnet build /p:BuildNumber="$BUILD_NUMBER" WebJobs.Script.sln && \
    dotnet publish /p:BuildNumber="$BUILD_NUMBER" src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --runtime linux-arm --output /azure-functions-host

FROM microsoft/azure-functions-python3.6:arm32v7-python3.6-deps
ARG HOST_TAG
ARG WORKER_TAG

COPY --from=host-build-env ["/azure-functions-host", "/azure-functions-host"]

# Install python worker
RUN [ "cross-build-start" ]
RUN wget https://github.com/Azure/azure-functions-python-worker/archive/${WORKER_TAG}.tar.gz && \
    tar xvzf ${WORKER_TAG}.tar.gz && \
    mv azure-functions-python-worker-* azure-functions-python-worker && \
    cp -R /azure-functions-python-worker/python /azure-functions-host/workers/python

COPY ./start.sh /azure-functions-host/workers/python/
COPY ./worker.config.json /azure-functions-host/workers/python/
ENV workers:python:path /azure-functions-host/workers/python/start.sh

RUN pip install git+https://github.com/Azure/azure-functions-python-worker.git@${WORKER_TAG}#egg=azure-functions-python
# End Install python workeri

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
