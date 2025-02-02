ARG BASE_IMAGE
ARG CONTENT_PKG
FROM ${BASE_IMAGE}

ARG CONTENT_PKG

ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY ${CONTENT_PKG} content.zip

RUN apt-get update && \
    apt-get install -y zip unzip curl && \
    mkdir -p /home/site/wwwroot && \
    yes | unzip -q content.zip -d /home/site/wwwroot
