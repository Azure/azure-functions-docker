FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.1
ARG HOST_VERSION
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=node \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}


COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]
COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]