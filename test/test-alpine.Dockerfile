ARG BASE_IMAGE
ARG CONTENT_URL
FROM ${BASE_IMAGE}

ARG CONTENT_URL

ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true

RUN apk update && apk add --no-cache zip unzip curl && \
    curl -o content.zip "${CONTENT_URL}" && \
    mkdir -p /home/site/wwwroot && \
    yes | unzip -q content.zip -d /home/site/wwwroot
