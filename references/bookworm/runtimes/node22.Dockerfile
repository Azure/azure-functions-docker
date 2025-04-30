# Build the runtime from source
ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE

FROM ${HOST_WORKER_IMAGE} AS workerImage-dotnet8
FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbookworm-runtime

ENV FUNCTIONS_WORKER_RUNTIME=node \
    ASPNETCORE_URLS=http://+:80

COPY --from=workerImage-dotnet8 [ "/workers/node", "/azure-functions-host/workers/node"  ]

RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs

CMD [ "/opt/startup/start_nonappservice.sh" ]