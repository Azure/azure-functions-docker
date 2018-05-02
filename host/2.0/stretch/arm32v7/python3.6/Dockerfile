ARG HOST_TAG=dev
ARG WORKER_TAG=dev
FROM microsoft/dotnet:2.0-sdk-stretch as host-build-env
ARG HOST_TAG
ARG WORKER_TAG

ENV PublishWithAspNetCoreTargetManifest false

# Install Runtime
RUN wget https://github.com/Azure/azure-functions-host/archive/${HOST_TAG}.tar.gz && \
    tar xvzf ${HOST_TAG}.tar.gz && \
    cd azure-functions-host-${HOST_TAG} && \
    dotnet build WebJobs.Script.sln && \
    dotnet publish src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --runtime linux-arm --output /azure-functions-host

FROM microsoft/azure-functions-python3.6:arm32v7-python3.6-deps-grpc
ARG HOST_TAG
ARG WORKER_TAG

COPY --from=host-build-env ["/azure-functions-host", "/azure-functions-host"]

# Install python worker
RUN [ "cross-build-start" ]
RUN wget https://github.com/Azure/azure-functions-python-worker/archive/${WORKER_TAG}.tar.gz && \
    tar xvzf ${WORKER_TAG}.tar.gz && \
    mv azure-functions-python-worker-* azure-functions-python-worker && \
    cp -R /azure-functions-python-worker/python /azure-functions-host/workers/python

ENV workers:config:path /workers/azure-functions-python-worker
COPY ./start.sh /workers/azure-functions-python-worker/python/
COPY ./worker.config.json /workers/azure-functions-python-worker/python/
ENV workers:python:path /workers/azure-functions-python-worker/python/start.sh
# End Install python worker

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
