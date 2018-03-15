ARG NAMESPACE=microsoft
FROM python:3.6.4-stretch as python-env

RUN apt-get update && \
    apt-get install -y git

RUN git clone https://github.com/Azure/azure-functions-python-worker.git

ARG NAMESPACE=microsoft
FROM ${NAMESPACE}/azure-functions-base:dev-stretch

COPY --from=python-env ["azure-functions-python-worker", "workers/azure-functions-python-worker"]

## Install pyenv

ENV PYENV_ROOT /root/.pyenv
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN apt-get update && \
    apt-get install -y git mercurial build-essential libssl-dev zlib1g-dev libreadline-dev libsqlite3-dev curl && \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

RUN pyenv install 3.6.4

RUN pyenv global 3.6.4

RUN cd workers && \
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
