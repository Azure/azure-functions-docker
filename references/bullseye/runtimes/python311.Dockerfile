# Build the runtime from source
ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE
ARG PIP_INDEX_URL

FROM mcr.microsoft.com/mirror/docker/library/python:3.11-slim-bullseye AS python311-builder
FROM ${HOST_WORKER_IMAGE} AS workerImage-dotnet8
FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbullseye-runtime
ARG HOST_VERSION
ARG PIP_INDEX_URL

ENV FUNCTIONS_WORKER_RUNTIME=python \
    FUNCTIONS_WORKER_RUNTIME_VERSION=3.11 \
    ASPNETCORE_URLS=http://+:80 \
    LANG=C.UTF-8 \
    ACCEPT_EULA=Y \
    DOTNET_RUNNING_IN_CONTAINER=true

# Install Python dependencies
# MS SQL related packages: unixodbc msodbcsql17 mssql-tools
# .NET Core dependencies: --no-install-recommends ca-certificates libc6 libgcc1 libgssapi-krb5-2 libicu67 libssl1.1 libstdc++6 zlib1g
# OpenCV dependencies:libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb
# binutils: binutils
# OpenMP dependencies: libgomp1 && \
# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157 : libc-dev
# Azure ML dependencies: liblttng-ust0
RUN apt-get update && \
    apt-get install -y wget apt-transport-https curl gnupg locales && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    curl https://packages.microsoft.com/config/debian/11/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
    # Needed for libss1.0.0 and in turn MS SQL
    echo 'deb http://security.debian.org/debian-security bullseye-security main' >> /etc/apt/sources.list && \
    # install MS SQL related packages.
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y unixodbc msodbcsql18 mssql-tools18 &&\
    apt-get install -y --no-install-recommends ca-certificates \
    libc6 libgcc1 libgssapi-krb5-2 libicu67 libssl1.1 libstdc++6 zlib1g &&\
    apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb binutils\
    binutils libgomp1 libc-dev liblttng-ust0 default-libmysqlclient-dev && \
    rm -rf /var/lib/apt/lists/*

# Chrome Headless Dependencies (01/2023)
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#chrome-headless-doesnt-launch-on-unix
RUN apt-get update && \
    apt-get install -y ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 \
    libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 \
    libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 \
    libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils

COPY --from=workerImage-dotnet8 [ "/workers/python/3.11/LINUX", "/azure-functions-host/workers/python/3.11/LINUX" ]
COPY --from=workerImage-dotnet8 [ "/workers/python/worker.config.json", "/azure-functions-host/workers/python" ]
COPY --from=python311-builder [ "/usr", "/usr" ]
COPY --from=python311-builder [ "/lib", "/lib" ]
COPY --from=python311-builder [ "/lib64", "/lib64" ]

# Install python packages
RUN if [ -n "${PIP_INDEX_URL}" ]; then \
    pip install -i ${PIP_INDEX_URL} ptvsd; \
    else \
    pip install ptvsd; \
    fi

CMD [ "/opt/startup/start_nonappservice.sh" ]