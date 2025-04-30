# Build the runtime from source
ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE
ARG PIP_INDEX_URL

FROM mcr.microsoft.com/oryx/python:3.12-debian-bookworm AS python312-builder
FROM ${HOST_WORKER_IMAGE} AS workerImage-dotnet8
FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbookworm-runtime
ARG PIP_INDEX_URL

ENV FUNCTIONS_WORKER_RUNTIME=python \
    ASPNETCORE_URLS=http://+:80 \
    FUNCTIONS_WORKER_RUNTIME_VERSION=3.12 \
    LANG=C.UTF-8 \
    ACCEPT_EULA=Y \
    DOTNET_RUNNING_IN_CONTAINER=true \
    LD_LIBRARY_PATH=/opt/python/3.12/lib:$LD_LIBRARY_PATH

# Install Python dependencies
RUN apt-get update && \
    apt-get install -y wget apt-transport-https curl gnupg2 locales && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo "deb [arch=amd64] https://packages.microsoft.com/debian/12/prod bookworm main" | tee /etc/apt/sources.list.d/mssql-release.list && \
    # Needed for libss3 and in turn MS SQL
    echo 'deb http://security.debian.org/debian-security bookworm-security main' >> /etc/apt/sources.list && \
    curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
    # install MS SQL related packages.pinned version in PR # 1012.
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    apt-get update && \
    # MS SQL related packages: unixodbc msodbcsql18 mssql-tools
    ACCEPT_EULA=Y apt-get install -y unixodbc msodbcsql18 mssql-tools18 && \
    # OpenCV dependencies:libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb
    apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb && \
    # .NET Core dependencies: ca-certificates libc6 libgcc1 libgssapi-krb5-2 libicu72 libssl3 libstdc++6 zlib1g 
    # Azure ML dependencies: liblttng-ust0
    # OpenMP dependencies: libgomp1
    # binutils: binutils
    apt-get install -y --no-install-recommends ca-certificates \
    libc6 libgcc1 libgssapi-krb5-2 libicu72 libssl3 libstdc++6 zlib1g && \
    apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb binutils \
    libgomp1 liblttng-ust1 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=workerImage-dotnet8 [ "/workers/python/3.12/LINUX", "/azure-functions-host/workers/python/3.12/LINUX" ]
COPY --from=workerImage-dotnet8 [ "/workers/python/worker.config.json", "/azure-functions-host/workers/python" ]
COPY --from=python312-builder [ "/opt", "/opt" ]

# Link all binaries from /opt/python/3.12/bin to /usr/bin/
RUN for file in /opt/python/3.12/bin/*; do \
        ln -sf "$file" /usr/bin/$(basename "$file"); \
    done

RUN ln -s /opt/python/3.12/lib/libpython3.12.so.1.0 /usr/lib/libpython3.12.so.1.0

# Install opentelemetry packages
RUN if [ -n "${PIP_INDEX_URL}" ]; then \
    pip install -i ${PIP_INDEX_URL} azure-monitor-opentelemetry-exporter azure-monitor-opentelemetry; \
    else \
    pip install azure-monitor-opentelemetry-exporter azure-monitor-opentelemetry; \
    fi

CMD [ "/opt/startup/start_nonappservice.sh" ]