ARG BASE_IMAGE
ARG CONTENT_URL
FROM ${BASE_IMAGE}

ARG CONTENT_URL

ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true

RUN curl -O https://packages.microsoft.com/azurelinux/3.0/prod/base/x86_64/Packages/u/unzip-6.0-21.azl3.x86_64.rpm
RUN tdnf install -y unzip-6.0-21.azl3.x86_64.rpm

RUN curl -o content.zip "${CONTENT_URL}" && \
    mkdir -p /home/site/wwwroot && \
    yes | unzip -q content.zip -d /home/site/wwwroot
