ARG HOST_COMMIT=dev
ARG BUILD_NUMBER=00001
FROM microsoft/dotnet:2.1-sdk AS installer-env
ARG HOST_COMMIT
ARG BUILD_NUMBER

ENV PublishWithAspNetCoreTargetManifest false

RUN export ARG_BUILD_NUMBER=${BUILD_NUMBER} && \
    if [ $ARG_BUILD_NUMBER = dev ]; \
    then export SCRIPT_BUILD_NUMBER=00001; \
    else export SCRIPT_BUILD_NUMBER=$(echo $ARG_BUILD_NUMBER | cut -d'.' -f 3 | cut -d'-' -f 1); \
    fi && \
    echo "Build Number == $SCRIPT_BUILD_NUMBER" &&\
    wget https://github.com/Azure/azure-functions-host/archive/${HOST_COMMIT}.tar.gz && \
    tar xvzf ${HOST_COMMIT}.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish /p:BuildNumber="$SCRIPT_BUILD_NUMBER" /p:CommitHash=${HOST_COMMIT} src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host

FROM arm32v7/debian:stretch-slim AS grpc-build

COPY ./qemu-arm-static /usr/bin/

ENV GRPC_VERSION=v1.12.x

RUN apt-get update && \
    apt-get install --yes build-essential autoconf libtool pkg-config \
    libgflags-dev libgtest-dev clang libc++-dev automake git

RUN git clone --depth 1 -b "$GRPC_VERSION" https://github.com/grpc/grpc && \
    cd grpc && \
    git submodule update --init && \
    make grpc_csharp_ext

# Runtime image
FROM microsoft/dotnet:2.1-runtime-stretch-slim-arm32v7

COPY --from=installer-env ["/azure-functions-host", "/azure-functions-host"]
COPY --from=grpc-build ["/grpc/libs/opt/libgrpc_csharp_ext.so.1.12.1", "/"]
COPY ./qemu-arm-static /usr/bin
COPY ./run-host.sh /azure-functions-host/run-host.sh

RUN chmod +x /azure-functions-host/run-host.sh && \
    rm -f /azure-functions-host/runtimes/linux/native/* && \
    cp libgrpc_csharp_ext.so.1.12.1 /azure-functions-host/runtimes/libgrpc_csharp_ext.so

RUN mkdir -p /home/site/wwwroot

ENV AzureWebJobsScriptRoot=/home/site/wwwroot
ENV HOME=/home
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

RUN rm /usr/bin/qemu-arm-static

ENTRYPOINT [ "/azure-functions-host/run-host.sh" ]