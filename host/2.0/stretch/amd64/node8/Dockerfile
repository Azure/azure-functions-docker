ARG NAMESPACE=microsoft
ARG HOST_TAG=dev-nightly
FROM ${NAMESPACE}/azure-functions-base:${HOST_TAG}

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs