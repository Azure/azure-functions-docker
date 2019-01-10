ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base
ARG BASE_IMAGE_TAG=2.0

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

ENV WORKER_TAG=1.0.0a6 \
    AZURE_FUNCTIONS_PACKAGE_VERSION=1.0.0a5 \
    LANG=C.UTF-8 \
    PYTHON_VERSION=3.7.0 \
    PYTHON_PIP_VERSION=18.0 \
    PYENV_ROOT=/root/.pyenv \
    ACCEPT_EULA=Y \
    PATH=/root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update && \
    apt-get install -y git wget

RUN wget https://github.com/Azure/azure-functions-python-worker/archive/$WORKER_TAG.tar.gz && \
    tar xvzf $WORKER_TAG.tar.gz && \
    mv azure-functions-python-worker-* azure-functions-python-worker

RUN cp -R /azure-functions-python-worker/python /azure-functions-host/workers/python

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && \
    apt-get install apt-transport-https

# Support for MSSQL ODBC
RUN apt-get update && apt-get install -my wget gnupg
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list

# Needed for libss1.0.0 and in turn MS SQL
RUN echo 'deb http://security.debian.org/debian-security jessie/updates main' >> /etc/apt/sources.list

# install necessary locales for MS SQL
RUN apt-get update && apt-get install -y locales \
    && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
    && locale-gen

# install MS SQL related packages
RUN apt-get update && \
    apt-get install -y debconf libcurl3 libc6 openssl libstdc++6 libkrb5-3 unixodbc msodbcsql17 mssql-tools libssl1.0.0

RUN apt-get update && \
    apt-get install -y git make build-essential libssl-dev zlib1g-dev libbz2-dev  \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libpq-dev python3-dev libevent-dev unixodbc-dev && \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

RUN PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install ${PYTHON_VERSION}

RUN pyenv global ${PYTHON_VERSION}

RUN pip install pip==${PYTHON_PIP_VERSION} && \
    pip install azure-functions==$AZURE_FUNCTIONS_PACKAGE_VERSION azure-functions-worker==$WORKER_TAG


# This is a monkey patch, we discuss whether this is a good thing.
COPY ./python-context/start.sh /azure-functions-host/workers/python/
RUN chmod +x /azure-functions-host/workers/python/start.sh

COPY ./python-context/worker.config.json /azure-functions-host/workers/python/
ENV workers:python:path /azure-functions-host/workers/python/start.sh
