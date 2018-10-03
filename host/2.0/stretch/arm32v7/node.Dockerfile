ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base
ARG BASE_IMAGE_TAG=2.0-arm32v7
FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

COPY ./qemu-arm-static /usr/bin

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs

RUN rm /usr/bin/qemu-arm-static