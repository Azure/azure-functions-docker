# Build the runtime from source
ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE
FROM ${HOST_WORKER_IMAGE} AS workerImage-dotnet8
FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbookworm-runtime

COPY --from=workerImage-dotnet8 ["/workers/powershell/worker.config.json", "/azure-functions-host/workers/powershell/worker.config.json"]
COPY --from=workerImage-dotnet8 ["/workers/powershell/7.4", "/azure-functions-host/workers/powershell/7.4"]

ENV FUNCTIONS_WORKER_RUNTIME=powershell \
    FUNCTIONS_WORKER_RUNTIME_VERSION=7.4 \
    ASPNETCORE_URLS=http://+:80

# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
RUN apt-get update && \
    apt-get install -y libc-dev

CMD [ "/opt/startup/start_nonappservice.sh" ]