ARG BASE_IMAGE_TAG=dev
FROM azure-functions/base:${BASE_IMAGE_TAG}

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs