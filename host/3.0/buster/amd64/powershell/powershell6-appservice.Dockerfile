# Build the runtime from source
ARG HOST_VERSION=3.0.15417
FROM functionshost:1.0.0 AS runtime-image

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2
ARG HOST_VERSION

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=powershell \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}


COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image ["/FuncExtensionBundles", "/FuncExtensionBundles"]
COPY --from=runtime-image [ "/workers/powershell/6", "/azure-functions-host/workers/powershell/6" ]
COPY --from=runtime-image [ "/workers/powershell/worker.config.json", "/azure-functions-host/workers/powershell/" ]

EXPOSE 2222 80

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server dialog && \
    echo "root:Docker!" | chpasswd

COPY sshd_config /etc/ssh/
COPY start.sh /azure-functions-host/

RUN chmod +x /azure-functions-host/start.sh

ENTRYPOINT ["/azure-functions-host/start.sh"]