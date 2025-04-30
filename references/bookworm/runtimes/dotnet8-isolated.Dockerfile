ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE

FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbookworm-runtime

ENV FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    ASPNETCORE_URLS=http://+:80 \
    FUNCTIONS_WORKER_RUNTIME_VERSION=8.0

EXPOSE 80

RUN apt-get update && \
    apt-get install -y libc-dev

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg wget unzip curl dialog openssh-server && \
    # Add remote dotnet debugger
    curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v vs2017u5 -l /root/vsdbg

CMD [ "/opt/startup/start_nonappservice.sh" ]