ARG NAMESPACE=microsoft
ARG HOST_TAG=dev-nightly
FROM ${NAMESPACE}/azure-functions-base:${HOST_TAG}

RUN curl -sL https://deb.nodesource.com/setup_8.x | -E bash - && \
    apt-get update && \
    apt-get install -y nodejs