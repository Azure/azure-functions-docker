ARG HOST_TAG=dev-nightly
ARG NAMESPACE=microsoft
FROM ${NAMESPACE}/azure-functions-python3.6:${HOST_TAG}

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs
