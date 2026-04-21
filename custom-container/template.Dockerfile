## This file contains steps to build your own dockerfile to run Function apps on Linux, with Java as example.

# Get the latest Host from https://github.com/Azure/azure-functions-host/releases
ARG HOST_VERSION=4.1044.400

# Get the latest extension bundle version from https://github.com/Azure/azure-functions-extension-bundles/releases
ARG EXTENSION_BUNDLE_VERSION_V4=4.28.0

## Build the Host which is currently written in .net 8
# Other available dotnet SDK tags can be found at https://github.com/dotnet/dotnet-docker/blob/main/README.sdk.md
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim-amd64 AS host-builder
ARG HOST_VERSION
ARG EXTENSION_BUNDLE_VERSION_V4

# Step 1: clone and build the Host repo into /azure-functions-host
RUN git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    dotnet restore --verbosity detailed src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj && \
    dotnet publish -v q /p:CI=true src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --self-contained --runtime linux-x64

# Step 2: download the extension bundles and put them in the expected folder structure under /FuncExtensionBundles
RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    EXTENSION_BUNDLE_VERSION_V4=${EXTENSION_BUNDLE_VERSION_V4} && \
    EXTENSION_BUNDLE_FILENAME_V4=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V4}_linux-x64.zip && \
    wget https://cdn.functions.azure.com/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4/$EXTENSION_BUNDLE_FILENAME_V4 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V4 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V4 &&\
    find /FuncExtensionBundles/ -type f -exec chmod 644 {} \;

## Main image extends from dotnet's runtime-deps to be able to run self-contained host.
# Other available dotnet runtime-deps tags can be found at https://github.com/dotnet/dotnet-docker/blob/main/README.runtime-deps.md
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-bookworm-slim-amd64
ARG HOST_VERSION

# copy the built host
COPY --from=host-builder [ "/azure-functions-host", "/azure-functions-host" ]
# copy the downloaded extension bundles
COPY --from=host-builder [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

# set env variables
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=$HOST_VERSION \ 
    PORT=80 \
    ASPNETCORE_URLS=http://+:80
    
# install language runtime and set related Env variables
# Java as an example below
ARG JAVA_VERSION=17.0.14
ARG JAVA_HOME=/usr/lib/jvm/msft-17-x64

ENV FUNCTIONS_WORKER_RUNTIME=java \
    JAVA_HOME=${JAVA_HOME}

RUN apt-get update && \
    apt-get install -y wget && \
    wget https://aka.ms/download-jdk/microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz && \
    mkdir -p ${JAVA_HOME} && \
    tar -xzf microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz -C ${JAVA_HOME} --strip-components=1 && \
    rm -f microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz

## for dotnet-isolated
# ENV FUNCTIONS_WORKER_RUNTIME=dotnet-isolated
# # Get necessary dotnet runtime
# COPY --from=mcr.microsoft.com/dotnet/aspnet:9.0-bookworm-slim-amd64 [ "/usr/share/dotnet", "/usr/share/dotnet" ]

## for node
# ENV FUNCTIONS_WORKER_RUNTIME=node
# RUN apt-get update && \
#     apt-get install -y curl gnupg && \
#     curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
#     apt-get update && \
#     apt-get install -y nodejs

## for powershell
# ENV FUNCTIONS_WORKER_RUNTIME=powershell \
#     FUNCTIONS_WORKER_RUNTIME_VERSION=7.4 \

## for python
# ENV FUNCTIONS_WORKER_RUNTIME=python \
#     ASPNETCORE_URLS=http://+:80 \
#     FUNCTIONS_WORKER_RUNTIME_VERSION=3.14 \
# Install Python on the image

## install any other packages or dependencies needed optionally

## ca-certificates step: Put your custom CA certificates in the ca_certificates folder
## and uncomment the following lines to have them installed in the image
# COPY /ca_certificates/* /usr/local/share/ca-certificates/
# RUN update-ca-certificates

## If we want to run the app in `app` user mode, give the user access to some of the directories
# RUN usermod -s /bin/bash app && \
# mkdir -p /home/site/wwwroot && \
# mkdir -p /local/sitepackages && \
# mkdir -p /tmp/metrics && \
# chown -R app:app /home && \
# chown -R app:app /local && \
# chown -R app:app /tmp/metrics
# RUN mkdir /azure-functions-host/Secrets && \
#  chown -R app:app /azure-functions-host/Secrets && \
#  chmod -R 777 /azure-functions-host/Secrets
# USER app

# start the host
CMD ["/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost"]

## OPTIONAL Additional steps for enabling ssh from Kudu and debugging in AppServices
## Note: This doesn't work with `app` user mode, needs root user mode

# EXPOSE 2222 80

# ENV SSH_PORT=2222

# RUN apt-get update && \
#    apt-get install -y --no-install-recommends openssh-server dialog && \
#    echo "root:Docker!" | chpasswd

### Configure SSH
# RUN echo "Port $SSH_PORT" > /etc/ssh/sshd_config && \
#     echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config && \
#     echo "LoginGraceTime 180" >> /etc/ssh/sshd_config && \
#     echo "X11Forwarding yes" >> /etc/ssh/sshd_config && \
#     echo "Ciphers aes128-cbc,3des-cbc,aes256-cbc" >> /etc/ssh/sshd_config && \
#     echo "MACs hmac-sha1,hmac-sha1-96" >> /etc/ssh/sshd_config && \
#     echo "StrictModes yes" >> /etc/ssh/sshd_config && \
#     echo "SyslogFacility DAEMON" >> /etc/ssh/sshd_config && \
#     echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
#     echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config && \
#     echo "PermitRootLogin yes" >> /etc/ssh/sshd_config


### As part of container startup, run all the below
# RUN echo '#!/bin/bash' > /startup.sh && \
#     ## set up debugging for Node and Python workers.TBD, link more documentation and exact steps needed.
#     echo 'if [ "$APPSVC_REMOTE_DEBUGGING" == "TRUE" ]; then' >> /startup.sh && \
#     echo '    export languageWorkers__node__arguments="--inspect=0.0.0.0:$APPSVC_TUNNEL_PORT"' >> /startup.sh && \
#     echo '    export languageWorkers__python__arguments="-m ptvsd --host localhost --port $APPSVC_TUNNEL_PORT"' >> /startup.sh && \
#     echo 'fi' >> /startup.sh && \
#     # Get environment variables to show up in SSH session
#     echo 'printenv | sed -n "s/^\([^=]\+\)=\(.*\)$/export \1=\2/p" | sed "s/\\\\/\\\\\\\\/g" | sed "s/\`/\\\\\`/g" | sed "s/\\$/\\\\$/g" | sed "s/\"/\\\\\"/g" | sed "/=/s//=\"/" | sed "s/$/\"/" >> /etc/profile' >> /startup.sh && \
#     # starting sshd process
#     echo 'service ssh start' >> /startup.sh && \
#     # start the host
#     echo '/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost' >> /startup.sh && \
#     chmod +x /startup.sh

# CMD ["/startup.sh"]

