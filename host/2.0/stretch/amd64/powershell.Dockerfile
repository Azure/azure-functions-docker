ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base:2.0
FROM ${BASE_IMAGE} as runtime-image
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=powershell

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image [ "/workers/powershell", "/azure-functions-host/workers/powershell" ]

CMD [ "dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll" ]