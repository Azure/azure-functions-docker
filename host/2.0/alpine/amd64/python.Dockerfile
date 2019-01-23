ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base:2.0-alpine
FROM ${BASE_IMAGE} as runtime-image

FROM microsoft/dotnet:2.2-aspnetcore-runtime-alpine

# Install Python dependencies
RUN apk add --no-cache libc6-compat libnsl wget git curl bash libffi-dev openssl-dev bzip2-dev zlib-dev readline-dev sqlite-dev build-base && \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
    # workaround for https://github.com/grpc/grpc/issues/17255
    ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1

ENV PYENV_ROOT=/root/.pyenv \
    PATH=/root/.pyenv/shims:/root/.pyenv/bin:$PATH

# Install Python
RUN PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.6.6 && \
    pyenv global 3.6.6 && \
    pip install pip==18.0

RUN export WORKER_TAG=1.0.0a6 && \
    export AZURE_FUNCTIONS_PACKAGE_VERSION=1.0.0a5 && \
    wget --quiet https://github.com/Azure/azure-functions-python-worker/archive/$WORKER_TAG.tar.gz && \
    tar xvzf $WORKER_TAG.tar.gz && \
    mv azure-functions-python-worker-* azure-functions-python-worker && \
    mv /azure-functions-python-worker/python /python && \
    rm -rf $WORKER_TAG.tar.gz /azure-functions-python-worker

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=python

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
RUN mv /python /azure-functions-host/workers

# Add custom worker config
COPY ./python-context/start.sh /azure-functions-host/workers/python/
COPY ./python-context/worker.config.json /azure-functions-host/workers/python/
RUN chmod +x /azure-functions-host/workers/python/start.sh

CMD [ "dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll" ]