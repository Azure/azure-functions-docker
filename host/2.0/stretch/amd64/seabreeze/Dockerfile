FROM microsoft/dotnet:2.0-sdk-stretch AS installer-env

ARG TAG=ahmels-seabreeze
ENV PublishWithAspNetCoreTargetManifest false

RUN wget https://github.com/Azure/azure-functions-host/archive/${TAG}.tar.gz && \
    tar xvzf ${TAG}.tar.gz && \
    cd azure-functions-host-${TAG} && \
    dotnet build WebJobs.Script.sln && \
    dotnet publish src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-runtime

RUN wget https://github.com/Azure/azure-functions-python-worker/archive/dev.tar.gz && \
    tar xvzf dev.tar.gz && \
    mv azure-functions-python-worker-dev azure-functions-python-worker

# Runtime image
FROM microsoft/dotnet:2.0-runtime-stretch

COPY --from=installer-env ["/azure-functions-runtime", "/azure-functions-runtime"]
COPY --from=installer-env ["/azure-functions-python-worker", "/azure-functions-python-worker"]
RUN cp -R /azure-functions-python-worker/python /azure-functions-runtime/workers/python

## Install pyenv

ENV PYENV_ROOT /root/.pyenv
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN apt-get update && \
    apt-get install -y git mercurial build-essential libssl-dev zlib1g-dev libreadline-dev libsqlite3-dev curl && \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

RUN pyenv install 3.6.4

RUN pyenv global 3.6.4

RUN /bin/bash -c \
    "python3 --version && \
    python3 -m venv worker_env && \
    source worker_env/bin/activate && \
    pip install -e git+https://github.com/Azure/azure-functions-python-worker.git@dev#egg=azure-functions"

# This is a monkey patch, we discuss whether this is a good thing.
COPY ./start.sh /azure-functions-runtime/workers/python/
COPY ./worker.config.json /azure-functions-runtime/workers/python/
ENV workers:python:path /azure-functions-runtime/workers/python/start.sh

# nvm version tag (should correspond with a release from https://github.com/creationix/nvm/releases)
ARG NVM_VERSION=v0.33.8

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.9.4

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install Node
# update the repository sources list
# and install dependencies
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get -y autoclean && \
    echo https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh && \
    curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh | bash && \
    /bin/bash -c \
    "source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm use default $NODE_VERSION"


ENV AzureWebJobsScriptRoot=/home/site/wwwroot
ENV HOME=/home
ENV WEBSITE_HOSTNAME=localhost:80
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

CMD ["dotnet", "/azure-functions-runtime/Microsoft.Azure.WebJobs.Script.WebHost.dll"]
