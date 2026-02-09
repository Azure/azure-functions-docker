# Built using the template.Dockerfile
ARG HOST_VERSION=4.1044.400

FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim-amd64 AS host-builder
ARG HOST_VERSION
ARG EXTENSION_BUNDLE_VERSION_V4=4.28.0

# Build host
RUN git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    dotnet restore --verbosity detailed src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj && \
    dotnet publish -v q /p:CI=true src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --self-contained --runtime linux-x64

# Download Ext Bundles
RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    EXTENSION_BUNDLE_VERSION_V4=${EXTENSION_BUNDLE_VERSION_V4} && \
    EXTENSION_BUNDLE_FILENAME_V4=Microsoft.Azure.Functions.ExtensionBundle.${EXTENSION_BUNDLE_VERSION_V4}_linux-x64.zip && \
    wget https://cdn.functions.azure.com/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4/$EXTENSION_BUNDLE_FILENAME_V4 && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    unzip /$EXTENSION_BUNDLE_FILENAME_V4 -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/$EXTENSION_BUNDLE_VERSION_V4 && \
    rm -f /$EXTENSION_BUNDLE_FILENAME_V4 &&\
    find /FuncExtensionBundles/ -type f -exec chmod 644 {} \;

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-bookworm-slim-amd64
ARG HOST_VERSION

COPY --from=host-builder [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=host-builder [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

# Set Env
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=$HOST_VERSION \ 
    PORT=80 \
    ASPNETCORE_URLS=http://+:80
    
# Install Java
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

# CMD ["/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost"]
# Additional steps to enable kudu ssh

EXPOSE 2222 80
ENV SSH_PORT=2222

RUN apt-get update && \
   apt-get install -y --no-install-recommends openssh-server dialog && \
   echo "root:Docker!" | chpasswd

## Configure SSH
RUN echo "Port $SSH_PORT" > /etc/ssh/sshd_config && \
    echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config && \
    echo "LoginGraceTime 180" >> /etc/ssh/sshd_config && \
    echo "X11Forwarding yes" >> /etc/ssh/sshd_config && \
    echo "Ciphers aes128-cbc,3des-cbc,aes256-cbc" >> /etc/ssh/sshd_config && \
    echo "MACs hmac-sha1,hmac-sha1-96" >> /etc/ssh/sshd_config && \
    echo "StrictModes yes" >> /etc/ssh/sshd_config && \
    echo "SyslogFacility DAEMON" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config


RUN echo '#!/bin/bash' > /startup.sh && \
    echo 'eval $(printenv | sed -n "s/^\([^=]\+\)=\(.*\)$/export \1=\2/p" | sed "s/\"/\\\\\"/g" | sed "/=/s//=\"/" | sed "s/$/\"/" >> /etc/profile)' >> /startup.sh && \
    echo 'service ssh start' >> /startup.sh && \
    echo '/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost' >> /startup.sh && \
    chmod +x /startup.sh

CMD ["/startup.sh"]