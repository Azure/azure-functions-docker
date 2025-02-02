ARG BASE_IMAGE
ARG CONTENT_PKG
FROM ${BASE_IMAGE}

ARG CONTENT_PKG

ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true

RUN curl -O https://packages.microsoft.com/azurelinux/3.0/prod/base/x86_64/Packages/u/unzip-6.0-21.azl3.x86_64.rpm
RUN tdnf install -y unzip-6.0-21.azl3.x86_64.rpm

COPY ${CONTENT_PKG} content.zip

RUN mkdir -p /home/site/wwwroot && \
    yes | unzip -q content.zip -d /home/site/wwwroot
