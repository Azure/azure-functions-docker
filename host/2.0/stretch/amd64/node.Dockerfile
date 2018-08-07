ARG NAMESPACE=microsoft
ARG HOST_TAG=dev
FROM azure-functions:${HOST_TAG}-base

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs