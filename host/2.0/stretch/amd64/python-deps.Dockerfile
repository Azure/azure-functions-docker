FROM python:3.6-slim-stretch

# Needs $PYTHON_WORKER_SRC_URL

ENV LANG=C.UTF-8 \
    ACCEPT_EULA=Y \
    AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=python \
    WORKER_TAG=1.0.0b10 \
    AZURE_FUNCTIONS_PACKAGE_VERSION=1.0.0b5 \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    PYTHON_WORKER_SRC_URL=${PYTHON_WORKER_SRC_URL}

# Install Python dependencies
RUN apt-get update && \
    apt-get install -y wget && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y apt-transport-https curl gnupg && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    # Needed for libss1.0.0 and in turn MS SQL
    echo 'deb http://security.debian.org/debian-security jessie/updates main' >> /etc/apt/sources.list && \
    # install necessary locales for MS SQL
    apt-get update && apt-get install -y locales && \
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    # install MS SQL related packages
    apt-get update && \
    apt-get install -y unixodbc msodbcsql17 mssql-tools && \
    wget --quiet ${PYTHON_WORKER_SRC_URL} && \
    tar xvzf *.tar.gz && \
    mv azure-functions-python-worker-* azure-functions-python-worker && \
    mv /azure-functions-python-worker/python /python && \
    rm -rf *.tar.gz && \
    python -m pip install -U -e /azure-functions-python-worker azure-functions==$AZURE_FUNCTIONS_PACKAGE_VERSION && \
    # .NET Core dependencies
    apt-get install -y --no-install-recommends ca-certificates \
    libc6 libgcc1 libgssapi-krb5-2 libicu57 liblttng-ust0 libssl1.0.2 libstdc++6 zlib1g && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /azure-functions-host/workers && \
    mv /python /azure-functions-host/workers