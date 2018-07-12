ARG NAMESPACE=microsoft
ARG HOST_TAG=dev-nightly
ARG WORKER_TAG=dev

FROM ${NAMESPACE}/azure-functions-base:${HOST_TAG}
ARG WORKER_TAG

RUN apt-get update && \
    apt-get install -y git wget

RUN wget https://github.com/Azure/azure-functions-python-worker/archive/${WORKER_TAG}.tar.gz && \
    tar xvzf ${WORKER_TAG}.tar.gz && \
    mv azure-functions-python-worker-* azure-functions-python-worker

RUN cp -R /azure-functions-python-worker/python /azure-functions-host/workers/python

## Install pyenv
ENV PYENV_ROOT /root/.pyenv
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN apt-get update && \
    apt-get install -y git make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev && \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

RUN pyenv install 3.6.4

RUN pyenv global 3.6.4

RUN pip install --upgrade pip && \
    pip install azure-functions azure-functions-worker


# This is a monkey patch, we discuss whether this is a good thing.
COPY ./start.sh /azure-functions-host/workers/python/
RUN chmod +x /azure-functions-host/workers/python/start.sh

COPY ./worker.config.json /azure-functions-host/workers/python/
ENV workers:python:path /azure-functions-host/workers/python/start.sh
