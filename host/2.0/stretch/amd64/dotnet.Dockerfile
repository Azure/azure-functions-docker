ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base:2.0
FROM ${BASE_IMAGE} as runtime-image

FROM microsoft/dotnet:2.2-aspnetcore-runtime

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]

CMD [ "dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll" ]