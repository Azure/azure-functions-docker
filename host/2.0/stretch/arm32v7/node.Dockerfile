ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base
ARG BASE_IMAGE_TAG=2.0-arm32v7

FROM arm32v7/node:8-stretch AS grpc-build-image
ARG BASE_IMAGE
ARG BASE_IMAGE_TAG

ENV GRPC_NPM_VERSION=1.12.3

COPY ./qemu-arm-static /usr/bin

RUN apt-get update && \
    apt-get install -y build-essential && \
    mkdir /node-grpc && \
    cd node-grpc && \
    npm install grpc@1.12.3

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

COPY ./qemu-arm-static /usr/bin
COPY --from=grpc-build-image [ "/node-grpc/node_modules/grpc/src/node/extension_binary/node-v57-linux-arm-glibc/grpc_node.node", "/grpc_node.node" ]

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    mkdir -p /azure-functions-host/workers/node/grpc/src/node/extension_binary/node-v57-linux-arm-glib && \
    mv /grpc_node.node /azure-functions-host/workers/node/grpc/src/node/extension_binary/node-v57-linux-arm-glibc/

RUN rm /usr/bin/qemu-arm-static