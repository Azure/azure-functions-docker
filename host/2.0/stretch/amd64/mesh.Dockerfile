ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/python
ARG BASE_IMAGE_TAG=dev-seabreeze

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs
