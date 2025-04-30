ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE

FROM ${HOST_BASE_IMAGE} AS linuxdedicatedtrixie-runtime

ENV FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    ASPNETCORE_URLS=http://+:80 \
    FUNCTIONS_WORKER_RUNTIME_VERSION=10.0

COPY --from=mcr.microsoft.com/dotnet/aspnet:10.0-preview-trixie-slim-amd64 [ "/usr/share/dotnet", "/usr/share/dotnet" ]

EXPOSE 80

RUN apt-get update && \
    apt-get install -y libc-dev

CMD [ "/opt/startup/start_nonappservice.sh" ]