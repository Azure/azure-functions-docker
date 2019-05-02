ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base:2.0-alpine
FROM ${BASE_IMAGE} as runtime-image

FROM openjdk:8-jdk-alpine as jdk
RUN mkdir -p /usr/lib/jvm/java-1.8-openjdk

FROM mcr.microsoft.com/dotnet/core/runtime-deps:2.2-alpine

RUN apk add --no-cache libc6-compat libnsl && \
    # workaround for https://github.com/grpc/grpc/issues/17255
    ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=java

COPY --from=runtime-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=runtime-image [ "/workers/java", "/azure-functions-host/workers/java" ]
COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

COPY --from=jdk /usr/lib/jvm/java-1.8-openjdk /usr/lib/jvm/java-1.8-openjdk
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]