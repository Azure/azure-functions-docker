#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM mcr.microsoft.com/oryx/python:3.12-debian-bookworm


ENV LANG=C.UTF-8 \
    ACCEPT_EULA=Y \
    AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=python \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true

# Install Python dependencies
# MS SQL related packages: unixodbc msodbcsql17 mssql-tools
# .NET Core dependencies: --no-install-recommends ca-certificates libc6 libgcc1 libgssapi-krb5-2 libicu67 libssl1.1 libstdc++6 zlib1g
# OpenCV dependencies:libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb
# binutils: binutils
# OpenMP dependencies: libgomp1
# Azure ML dependencies: liblttng-ust0
RUN apt-get update && \
    apt-get install -y wget apt-transport-https curl gnupg locales && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
    # Needed for libss1.0.0 and in turn MS SQL
    echo 'deb http://security.debian.org/debian-security bookworm-security main' >> /etc/apt/sources.list && \
    # install MS SQL related packages.pinned version in PR # 1012.
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y unixodbc msodbcsql18=18.2.2.1-1 mssql-tools18 &&\
    apt-get install -y --no-install-recommends ca-certificates \
    libc6 libgcc1 libgssapi-krb5-2 libicu67 libssl1.1 libstdc++6 zlib1g &&\
    apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb binutils\
    binutils libgomp1 liblttng-ust0 && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git unixodbc-dev dh-autoreconf \
    libcurl4-openssl-dev libssl-dev python3-dev libevent-dev python3-openssl squashfs-tools unzip

