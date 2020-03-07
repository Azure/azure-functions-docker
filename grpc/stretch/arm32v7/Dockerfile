FROM arm32v7/debian:stretch-slim as build-env

COPY ./qemu-arm-static /usr/bin/

ENV GRPC_VERSION=v1.20.x

RUN apt-get update && \
    apt-get install --yes build-essential autoconf libtool pkg-config \
    libgflags-dev libgtest-dev clang libc++-dev automake git

RUN git clone --depth 1 -b "$GRPC_VERSION" https://github.com/grpc/grpc && \
    cd grpc && \
    git submodule update --init && \
    make grpc_csharp_ext

FROM scratch

COPY --from=build-env ["/grpc/libs/opt/libgrpc_csharp_ext.so.1.20.1", "/"]

CMD ["dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll"]