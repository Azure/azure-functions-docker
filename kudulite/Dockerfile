FROM golang:1.13.1 as go-build-env
COPY /mesh /mesh
RUN cd /mesh && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o init

FROM mcr.microsoft.com/oryx/build:lts-versions-buster-20210201.1 as pre-final-env
ARG BRANCH
ARG NAMESPACE
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update \
  && apt-get install -y vim tree --no-install-recommends \
  && apt-get install -y tcptraceroute \
  # SQL Server gem support
  && apt-get install -y unixodbc-dev freetds-dev freetds-bin \
  # Install Squashfs tools for KuduLite build
  && apt-get install -y squashfs-tools \
  # Install Kudu dependencies
  && apt-get install -y unzip \
  && wget -O /usr/bin/tcpping http://www.vdberg.org/~richard/tcpping \
  && chmod 755 /usr/bin/tcpping

# Install Kudu
RUN mkdir -p /opt/Kudu/local \
  && chmod 755 /opt/Kudu/local \
  && mkdir -p /home/LogFiles \
  && chmod -R 777 /home \
  && rm -rf /tmp/*

COPY --from=go-build-env [ "/mesh/init", "/root/mesh/init" ]

ENV DOTNET_RUNNING_IN_CONTAINER=true

ENV MESH_INIT_URI=http://localhost:6060/

# Enable correct mode for dotnet watch (only mode supported in a container)
ENV DOTNET_USE_POLLING_FILE_WATCHER=true

# Skip extraction of XML docs - generally not useful within an image/container - helps performance
ENV NUGET_XMLDOC_MODE=skip

RUN dotnet tool install -g dotnet-aspnet-codegenerator --version 2.2.4
ENV PATH=$PATH:/root/.dotnet/tools

# Install Kudu (since oryx/build:20200929.1, benv dotnet only accept full version)
RUN cd /tmp \
    && git clone --depth 1 --branch $BRANCH https://github.com/$NAMESPACE/KuduLite.git KuduLite \
    && cd ./KuduLite/Kudu.Services.Web \
    && benv dotnet=3-lts dotnet publish -c Release -o /opt/Kudu \
    && chmod 777 /opt/Kudu/Kudu.Services.Web.dll \
    && rm -rf /tmp/* \
    && chmod a+rw /var/nuget \
    && find /var/nuget -type d -exec chmod 777 {} \;

COPY startup.sh /

RUN chmod 777 /startup.sh

RUN benv node=9 npm install -g kudusync pm2@latest

RUN ln -s /opt/nodejs/9/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm-cli.js
ENV PATH=$PATH:/opt/nodejs/9/bin

# Use Dynamic Install SDK feature from Oryx build
RUN rm -rf /opt/python /opt/hugo /opt/php /opt/php-composer /opt/npm \
    # We still need the fundamental ones when building the images nodejs 9 and dotnet
    && find /opt/nodejs -mindepth 1 -maxdepth 1 -type d,l -not -name "9*" | xargs rm -rf

ENV ENABLE_DYNAMIC_INSTALL=true

EXPOSE 80

# Squash all layers into a few
FROM scratch

COPY --from=pre-final-env / /

ENV AZURE_FUNCTIONS_ENVIRONMENT=production \
    DEBIAN_FRONTEND=noninteractive \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    ENABLE_DYNAMIC_INSTALL=true \
    HOME=/home \
    LANG=C.UTF-8 \
    MESH_INIT_URI=http://localhost:6060/ \
    NUGET_PACKAGES=/var/nuget \
    NUGET_XMLDOC_MODE=skip \
    ORIGINAL_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    ORYX_AI_INSTRUMENTATION_KEY=4aadba6b-30c8-42db-9b93-024d5c62b887 \
    ORYX_PATHS=/opt/oryx:/opt/nodejs/lts/bin:/opt/dotnet/sdks/lts:/opt/python/latest/bin:/opt/php/lts/bin:/opt/php-composer:/opt/yarn/stable/bin:/opt/hugo/lts \
    ORYX_SDK_STORAGE_BASE_URL=https://oryx-cdn.microsoft.io \
    PATH=/opt/oryx:/opt/nodejs/lts/bin:/opt/dotnet/sdks/lts:/opt/python/latest/bin:/opt/php/lts/bin:/opt/php-composer:/opt/yarn/stable/bin:/opt/hugo/lts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.dotnet/tools:/opt/nodejs/9/bin \
    PYTHONIOENCODING=UTF-8 \
    SHLVL=1 \
    TERM=xterm \
    WEBSITE_MOUNT_ENABLED=1 \
    WEBSITE_PLACEHOLDER_MODE=1

WORKDIR /

ENTRYPOINT [ "/startup.sh" ]

CMD [ "1002", "kudu_group", "1001", "root", "localsite" ]