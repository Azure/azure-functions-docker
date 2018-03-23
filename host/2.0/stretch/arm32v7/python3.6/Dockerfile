FROM microsoft/dotnet:2.0-sdk-stretch as host-build-env

ARG TAG=dev
ENV PublishWithAspNetCoreTargetManifest false

# Install Runtime
RUN wget https://github.com/Azure/azure-functions-host/archive/${TAG}.tar.gz && \
    tar xvzf ${TAG}.tar.gz && \
    cd azure-functions-host-${TAG} && \
    dotnet build WebJobs.Script.sln && \
    dotnet publish src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --runtime linux-arm --output /azure-functions-host

FROM arm32v7/python:3.6.4-stretch

COPY --from=host-build-env ["/azure-functions-host", "/azure-functions-host"]

ARG TAG=dev
# Install python worker
RUN wget https://github.com/Azure/azure-functions-python-worker/archive/${TAG}.tar.gz && \
    tar xvzf ${TAG}.tar.gz && \
    mkdir /workers && \
    mv azure-functions-python-worker-${TAG} /workers/azure-functions-python-worker && \
    rm ${TAG}.tar.gz && \
    cd workers && \
    /bin/bash -c \
    "python3 --version && \
    python3 -m venv worker_env && \
    source worker_env/bin/activate && \
    cd azure-functions-python-worker && \
    pip3 install -r requirements.txt &&  \
    python3 setup.py build && \
    pip install -U -e .[dev]"

ENV workers:config:path /workers/azure-functions-python-worker

# This is a monkey patch, we discuss whether this is a good thing.
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

CMD ["/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost"]
