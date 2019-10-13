# This Zulu OpenJDK Dockerfile and corresponding Docker image are
# to be used solely with Java applications or Java application components
# that are being developed for deployment on Microsoft Azure or Azure Stack,
# and are not intended to be used for any other purpose.

ARG BASE_IMAGE
FROM ${BASE_IMAGE} as runtime-image
# mcr.microsoft.com/java/jdk doesn't have a debian 10 image yet.
FROM mcr.microsoft.com/java/jdk:8u222-zulu-debian9 as jdk
FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.0

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=java \
    DOTNET_USE_POLLING_FILE_WATCHER=true

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=runtime-image [ "/workers/java", "/azure-functions-host/workers/java" ]
COPY --from=jdk [ "/usr/lib/jvm/zulu-8-azure-amd64", "/usr/lib/jvm/zulu-8-azure-amd64" ]

ENV JAVA_HOME /usr/lib/jvm/zulu-8-azure-amd64

COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]