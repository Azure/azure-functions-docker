
ARG HOST_VERSION=4.1036.0

FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim-amd64 AS runtime-image
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false \
    DEBIAN_FRONTEND=noninteractive 

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) && \
    git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host && \
    cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers && \
    rm -rf /root/.local /root/.nuget /src \;

FROM mcr.microsoft.com/dotnet/aspnet:8.0-bookworm-slim-amd64
ARG HOST_VERSION

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY sshd_config /etc/ssh/
COPY start.sh /azure-functions-host/
COPY install_ca_certificates.sh /opt/startup/

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    ASPNETCORE_URLS=http://+:80

# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
RUN apt-get update && \
    apt-get install -y libc-dev

EXPOSE 2222 80

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg wget unzip curl dialog openssh-server && \
    # Add remote dotnet debugger
    curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v vs2017u5 -l /root/vsdbg && \
    echo "root:Docker!" | chpasswd

# This is current not working with the .NET 6.0 image based on bullseye. Tracking here: https://github.com/Azure/azure-functions-docker/issues/451
# Chrome headless dependencies
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#chrome-headless-doesnt-launch-on-unix
# RUN apt-get install -y xvfb gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
#    libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 \
#    libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
#    libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
#    libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

RUN chmod +x /azure-functions-host/start.sh && \
    chmod +x /opt/startup/install_ca_certificates.sh

ENTRYPOINT ["/azure-functions-host/start.sh"]
