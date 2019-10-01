ARG BASE_PYTHON_IMAGE
FROM ${BASE_PYTHON_IMAGE}

RUN apt-get update && \
    apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git unixodbc-dev dh-autoreconf \
    libcurl4-openssl-dev libssl-dev python3-dev libevent-dev python-openssl squashfs-tools unzip && \
    python --version