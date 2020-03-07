ARG BASE_IMAGE
ARG CONTENT_URL
FROM debian:buster as qemu-image

RUN apt-get update && \
    apt-get install -y qemu-user qemu-user-static

FROM ${BASE_IMAGE}
ARG CONTENT_URL

COPY --from=qemu-image ["/usr/bin/qemu-arm-static", "/usr/bin"]

ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true

RUN apt-get update && \
    apt-get install -y zip unzip curl && \
    curl -o content.zip "${CONTENT_URL}" && \
    mkdir -p /home/site/wwwroot && \
    yes | unzip -q content.zip -d /home/site/wwwroot
