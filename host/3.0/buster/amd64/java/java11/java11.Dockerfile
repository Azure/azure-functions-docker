# Build the runtime from source
ARG HOST_VERSION=3.0.15571
ARG JAVA_VERSION=11u7
FROM functionshost:${HOST_VERSION} AS runtime-image
ARG JAVA_VERSION
FROM mcr.microsoft.com/java/jre-headless:${JAVA_VERSION}-zulu-debian10-with-tools as jre
FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.1
ARG HOST_VERSION

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=java \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=runtime-image [ "/workers/java", "/azure-functions-host/workers/java" ]
COPY --from=jre [ "/usr/lib/jvm/zre-hl-tools-11-azure-amd64", "/usr/lib/jvm/zre-11-azure-amd64" ]

ENV JAVA_HOME /usr/lib/jvm/zre-11-azure-amd64

COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]
