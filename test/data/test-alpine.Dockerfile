ARG BASE_IMAGE
ARG CONTENT_URL
FROM ${BASE_IMAGE}

ARG CONTENT_URL

RUN apk add --no-cache unzip wget && \
    wget --quiet -O content.zip "${CONTENT_URL}" && \
    mkdir -p /home/site/wwwroot && \
    unzip -q content.zip -d /home/site/wwwroot
