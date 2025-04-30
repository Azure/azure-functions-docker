ARG HOST_BASE_IMAGE

FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbullseye-runtime

ENV FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    ASPNETCORE_URLS=http://+:80 \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing \
    FUNCTIONS_WORKER_RUNTIME_VERSION=7.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg wget unzip curl dialog openssh-server && \
    # Add remote dotnet debugger
    curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v vs2017u5 -l /root/vsdbg

COPY --from=mcr.microsoft.com/dotnet/aspnet:7.0 [ "/usr/share/dotnet", "/usr/share/dotnet" ]

CMD [ "/opt/startup/start_nonappservice.sh" ]