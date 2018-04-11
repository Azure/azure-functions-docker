ARG NAMESPACE=microsoft
FROM ${NAMESPACE}/azure-functions-python3.6:dev-stretch

# nvm version tag (should correspond with a release from https://github.com/creationix/nvm/releases)
ARG NVM_VERSION=v0.33.8

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.9.4

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install Node
# update the repository sources list
# and install dependencies
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get -y autoclean && \
    echo https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh && \
    curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh | bash && \
    /bin/bash -c \
    "source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm use default $NODE_VERSION"
