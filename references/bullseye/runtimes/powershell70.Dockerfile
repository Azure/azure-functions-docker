# Build the runtime from source
ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE

FROM ${HOST_WORKER_IMAGE} AS workerImage-dotnet8
FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbullseye-runtime
ARG HOST_VERSION

ENV FUNCTIONS_WORKER_RUNTIME=powershell \
    FUNCTIONS_WORKER_RUNTIME_VERSION=~7 \
    ASPNETCORE_URLS=http://+:80

COPY --from=workerImage-dotnet8 [ "/workers/powershell", "/azure-functions-host/workers/powershell" ]
COPY --from=mcr.microsoft.com/dotnet/core/aspnet:3.1 /usr/share/dotnet /usr/share/dotnet

CMD [ "/opt/startup/start_nonappservice.sh" ]