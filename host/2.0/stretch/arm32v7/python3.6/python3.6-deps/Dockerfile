FROM resin/rpi-raspbian:stretch

# Install Python
ENV PYENV_ROOT /root/.pyenv
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN [ "cross-build-start" ]
RUN apt-get update && \
    apt-get install -y git make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev && \
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
RUN pyenv install 3.6.4
RUN pyenv global 3.6.4
RUN [ "cross-build-end" ]