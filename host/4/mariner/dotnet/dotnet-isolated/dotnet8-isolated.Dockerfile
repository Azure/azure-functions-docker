# Build the runtime from source
ARG HOST_VERSION=4.28.0
# host-builder
FROM mcr.microsoft.com/dotnet/sdk:6.0-cbl-mariner2.0 AS sdk-image 
ARG HOST_VERSION

ENV PublishWithAspNetCoreTargetManifest=false
RUN echo HOST_VERSION

RUN BUILD_NUMBER=$(echo ${HOST_VERSION} | cut -d'.' -f 3) 
RUN git clone --branch v${HOST_VERSION} https://github.com/Azure/azure-functions-host /src/azure-functions-host 
RUN cd /src/azure-functions-host && \
    HOST_COMMIT=$(git rev-list -1 HEAD) && \
    dotnet publish -v q /p:BuildNumber=$BUILD_NUMBER /p:CommitHash=$HOST_COMMIT src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj -c Release --output /azure-functions-host --runtime linux-x64 --no-self-contained
RUN mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers
RUN rm -rf /root/.local /root/.nuget /src

# Include ASP.NET Core shared framework from dotnet/aspnet image.
FROM mcr.microsoft.com/dotnet/aspnet:8.0-cbl-mariner2.0 AS aspnet8

FROM mcr.microsoft.com/dotnet/runtime:8.0-cbl-mariner2.0
ARG HOST_VERSION

# TODO
# RUN yum install -y dnf

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    HOST_VERSION=${HOST_VERSION} \
    ASPNETCORE_CONTENTROOT=/azure-functions-host \
    AzureWebJobsFeatureFlags=EnableWorkerIndexing

# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
# TODO
# RUN dnf install -y glibc-devel

COPY --from=sdk-image [ "/azure-functions-host", "/azure-functions-host" ]
COPY --from=aspnet8 [ "/usr/share/dotnet", "/usr/share/dotnet" ]

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]