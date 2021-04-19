# Build the runtime from source
ARG HOST_VERSION=3.0.15571
FROM functionshost:${HOST_VERSION} AS runtime-image

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim
ARG HOST_VERSION

# set runtime env variables
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=powershell \
    FUNCTIONS_WORKER_RUNTIME_VERSION=~7 \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION}

# copy bundles, host runtime and powershell worker from the build image
COPY --from=runtime-image ["/FuncExtensionBundles", "/FuncExtensionBundles"]
COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image ["/workers/powershell", "/azure-functions-host/workers/powershell"]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]
