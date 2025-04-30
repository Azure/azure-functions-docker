ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE

FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbookworm-runtime

ENV FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    ASPNETCORE_URLS=http://+:80 \
    FUNCTIONS_WORKER_RUNTIME_VERSION=9.0

COPY --from=mcr.microsoft.com/dotnet/aspnet:9.0-bookworm-slim-amd64 [ "/usr/share/dotnet", "/usr/share/dotnet" ]

EXPOSE 80

RUN apt-get update && \
    apt-get install -y libc-dev

CMD [ "/opt/startup/start_nonappservice.sh" ]