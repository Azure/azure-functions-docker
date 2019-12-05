ARG BASE_IMAGE
FROM ${BASE_IMAGE} as runtime-image
FROM openjdk:8-jdk as jdk
FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.1

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=java \
    DOTNET_USE_POLLING_FILE_WATCHER=true

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=runtime-image [ "/workers/java", "/azure-functions-host/workers/java" ]
COPY --from=jdk [ "/usr/local/openjdk-8", "/usr/local/openjdk-8" ]

ENV JAVA_HOME /usr/local/openjdk-8

COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]