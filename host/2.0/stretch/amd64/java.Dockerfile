ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base:2.0
FROM ${BASE_IMAGE} as runtime-image

FROM openjdk:8-jdk as jdk

FROM mcr.microsoft.com/dotnet/core/runtime-deps:2.2

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=java

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=runtime-image [ "/workers/java", "/azure-functions-host/workers/java" ]

COPY --from=jdk /docker-java-home /docker-java-home
ENV JAVA_HOME /docker-java-home

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]