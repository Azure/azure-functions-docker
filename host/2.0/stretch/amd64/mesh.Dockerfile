ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/python:2.0

FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS installer-env

ENV PublishWithAspNetCoreTargetManifest=false \
    HOST_VERSION=2.0.23456 \
    HOST_COMMIT=a53a3dcf283ed150f44cb5692d1fb7cae8ffc62f

RUN BUILD_NUMBER=$(echo $HOST_VERSION | cut -d'.' -f 3) && \
    wget https://github.com/pragnagopa/azure-functions-host/archive/$HOST_COMMIT.tar.gz && \
    tar xzf $HOST_COMMIT.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --runtime debian.9-x64 --output /azure-functions-host

FROM ubuntu:18.04 as squashfuse-build-env

RUN apt-get update && \
    apt-get install -y fuse-zip git build-essential pkg-config autoconf automake \
    libtool liblzma-dev zlib1g-dev liblzo2-dev liblz4-dev libfuse-dev libattr1-dev && \
    git clone --depth 1 https://github.com/vasi/squashfuse && \
    cd squashfuse && \
    ./autogen.sh && \
    ./configure && \
    make

FROM ${BASE_IMAGE} as pre-final-env

ENV ASPNETCORE_VERSION=2.2.3 \
    FUNCTIONS_WORKER_RUNTIME=

# Install node
RUN mv /azure-functions-host/workers/python /python && \
    rm -rf /azure-functions-host && \
    apt-get update && \
    apt-get install -y gnupg wget unzip curl && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    mkdir -p /azure-functions-host/workers && \
    mv /python /azure-functions-host/workers && \
    #Install certificates
    mkdir -p /azure-functions-host/certificates && \
    wget -O /azure-functions-host/certificates/ameroot.der http://crl.microsoft.com/pkiinfra/Certs/AMEROOT_ameroot.crt &&\
    wget -O /azure-functions-host/certificates/ameinfra01.der http://crl.microsoft.com/pkiinfra/Certs/BY2PKIINTCA01.AME.GBL_AME%20Infra%20CA%2001.crt &&\
    wget -O /azure-functions-host/certificates/ameinfra02.der http://crl.microsoft.com/pkiinfra/Certs/BL2PKIINTCA01.AME.GBL_AME%20Infra%20CA%2002.crt &&\
    openssl x509 -in /azure-functions-host/certificates/ameroot.der -inform der -out /usr/local/share/ca-certificates/ameroot.crt -outform pem &&\
    openssl x509 -in /azure-functions-host/certificates/ameinfra01.der -inform der -out /usr/local/share/ca-certificates/ameinfra01.crt -outform pem &&\
    openssl x509 -in /azure-functions-host/certificates/ameinfra02.der -inform der -out /usr/local/share/ca-certificates/ameinfra02.crt -outform pem &&\
    update-ca-certificates && \
    # Install fuze-zip
    apt-get install -y fuse-zip liblzo2-2 liblz4-1 liblzma5 zlib1g squashfs-tools && \
    # .NET Core for powershell
    curl -SL --output aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-x64.tar.gz \
    && aspnetcore_sha512='53be8489aafa132c1a7824339c9a0d25f33e6ab0c42f414a8bda014b60ff82a20144032bd7e887d375dc275bb5dbeb71d38c7f90c39016895df8d3cf3c4b7a95' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Add all workers
COPY --from=installer-env ["/azure-functions-host", "/azure-functions-host"]
COPY --from=squashfuse-build-env [ "/squashfuse", "/squashfuse" ]

ENV PATH="${PATH}:/squashfuse"

RUN wget https://github.com/pragnagopa/azure-functions-nodejs-worker/archive/7dcd31cb0230132655439a8c3cf08b6e34521531.tar.gz && \
    tar xzf 7dcd31cb0230132655439a8c3cf08b6e34521531.tar.gz && \
    cd azure-functions-nodejs-worker-* && \
    npm install && \
    npm run build-nomaps && \
    mkdir -p ./pkg/deps/grpc/etc/ && \
    mkdir -p ./pkg/grpc/ && \
    mkdir -p ./pkg/dist/src && \
    cp ./node_modules/grpc/deps/grpc/etc/roots.pem ./pkg/deps/grpc/etc/ && \
    cp ./node_modules/grpc/package.json ./pkg/grpc/ && \
    cp ./dist/src/nodejsWorker.js ./pkg/dist/src/ && \
    cp ./worker.config.json pkg && \
    cp ./src/functionCode.js ./pkg/dist/src/ && \
    ./node_modules/.bin/webpack && \
    # Node 8 support
    ./node_modules/.bin/node-pre-gyp install -C pkg/grpc --target_arch=x64 --target=8.4.0 --target_platform=linux --target_libc=glibc || true && \
    mv pkg node && \
    rm -rf /azure-functions-host/workers/node && \
    mv node /azure-functions-host/workers/

FROM scratch

COPY --from=pre-final-env / /

ENV LANG=C.UTF-8 \
    ASPNETCORE_URLS=http://+:80 \
    AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    ASPNETCORE_VERSION=2.2.3 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    TERM=xterm \
    PYTHON_VERSION=3.6.8 \
    PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/squashfuse

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]
