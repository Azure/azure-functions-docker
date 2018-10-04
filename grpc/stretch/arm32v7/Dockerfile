FROM arm32v7/debian:stretch-slim

COPY ./qemu-arm-static /usr/bin/

ENV GRPC_VERSION=v1.12.x

RUN apt-get update && \
    apt-get install --yes build-essential autoconf libtool pkg-config \
    libgflags-dev libgtest-dev clang libc++-dev automake git

RUN git clone --depth 1 -b "$GRPC_VERSION" https://github.com/grpc/grpc && \
    cd grpc && \
    git submodule update --init && \
    make grpc_csharp_ext

CMD cp /grpc/libs/opt/libgrpc_csharp_ext.so.* /output