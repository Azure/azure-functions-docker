ARG BASE_IMAGE
FROM ${BASE_IMAGE} as runtime-image

RUN rm -rf /azure-functions-host/runtimes

FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.0

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet \
    DOTNET_USE_POLLING_FILE_WATCHER=true

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]

COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]