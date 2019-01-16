ARG BASE_IMAGE
ARG CONTENT_URL
FROM ${BASE_IMAGE}

ARG CONTENT_URL

RUN apt-get update && \
    apt-get install -y unzip wget && \
    wget --quiet -O content.zip "${CONTENT_URL}" && \
    mkdir -p /home/site/wwwroot && \
    yes | unzip -q content.zip -d /home/site/wwwroot
