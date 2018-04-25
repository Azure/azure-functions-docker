ARG NAMESPACE=microsoft
FROM python:3.6.4-stretch as python-env

RUN apt-get update && \
    apt-get install -y git

RUN git clone https://github.com/Azure/azure-functions-python-worker.git

ARG NAMESPACE=microsoft
FROM ${NAMESPACE}/azure-functions-base:dev-stretch

COPY --from=python-env ["azure-functions-python-worker", "/azure-functions-python-worker"]

RUN cp -R /azure-functions-python-worker/python /azure-functions-runtime/workers/python

## Install pyenv

ENV PYENV_ROOT /root/.pyenv
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN apt-get update && \
    apt-get install -y git mercurial build-essential libssl-dev zlib1g-dev libreadline-dev libsqlite3-dev curl && \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

RUN pyenv install 3.6.4

RUN pyenv global 3.6.4

RUN pip install -e git+https://github.com/Azure/azure-functions-python-worker.git@dev#egg=azure-functions

# This is a monkey patch, we discuss whether this is a good thing.
COPY ./start.sh /azure-functions-runtime/workers/python/
COPY ./worker.config.json /azure-functions-runtime/workers/python/
ENV workers:python:path /azure-functions-runtime/workers/python/start.sh
