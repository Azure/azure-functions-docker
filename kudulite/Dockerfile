FROM mcr.microsoft.com/oryx/build:20191018.1 as main
ARG BRANCH
ARG NAMESPACE
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update \
  && apt-get install -y vim tree --no-install-recommends \
  && apt-get install -y tcptraceroute \
# Install Squashfs tools for KuduLite build
  && apt-get install -y squashfs-tools \
  && wget -O /usr/bin/tcpping http://www.vdberg.org/~richard/tcpping \
  && chmod 755 /usr/bin/tcpping

# SQL Server gem support
RUN apt-get install -y unixodbc-dev freetds-dev freetds-bin

# Install Kudu
RUN mkdir -p /opt/Kudu/local \
  && chmod 755 /opt/Kudu/local \
  && apt-get update \
  && apt-get  install -y unzip \
# Install pm2 and pm2-logrotate
  && mkdir -p /home/LogFiles \
  && chmod -R 777 /home \
  && rm -rf /tmp/*

ENV DOTNET_RUNNING_IN_CONTAINER=true

# Enable correct mode for dotnet watch (only mode supported in a container)
ENV DOTNET_USE_POLLING_FILE_WATCHER=true

# Skip extraction of XML docs - generally not useful within an image/container - helps performance
ENV NUGET_XMLDOC_MODE=skip

RUN dotnet tool install -g dotnet-aspnet-codegenerator --version 2.2.4
ENV PATH=$PATH:/root/.dotnet/tools

#Instal Kudu
RUN cd /tmp \
    && git clone https://github.com/$NAMESPACE/KuduLite.git \
    && cd ./KuduLite \
    && git checkout $BRANCH \
    && cd ./Kudu.Services.Web \
    && benv dotnet=2.2 dotnet publish -c Release -o /opt/Kudu \
    && chmod 777 /opt/Kudu/Kudu.Services.Web.dll \
    && rm -rf /tmp/* \
    && chmod a+rw /var/nuget \
    && find /var/nuget -type d -exec chmod 777 {} \;

COPY startup.sh /

RUN chmod 777 /startup.sh

RUN benv node=9 npm=6 npm install -g kudusync
RUN benv node=9 npm=6 npm install pm2@latest -g

RUN ln -s /opt/nodejs/9/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm-cli.js
ENV PATH=$PATH:/opt/nodejs/9/bin

EXPOSE 80

ENTRYPOINT [ "/startup.sh" ]
CMD [ "1002", "kudu_group", "1001", "root", "localsite" ]
