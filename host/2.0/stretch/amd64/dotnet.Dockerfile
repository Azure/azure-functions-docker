ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base:2.0
FROM ${BASE_IMAGE} as runtime-image

RUN rm -rf /azure-functions-host/runtimes

FROM mcr.microsoft.com/dotnet/core/runtime-deps:2.2

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]

COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]