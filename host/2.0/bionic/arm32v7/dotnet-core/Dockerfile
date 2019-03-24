
ARG HOST_TAG=v2.0.11888-alpha
FROM mcr.microsoft.com/dotnet/core/sdk:2.2 as host-build-env
ARG HOST_TAG

ENV PublishWithAspNetCoreTargetManifest false

# Install Runtime
RUN BUILD_NUMBER=$(echo ${HOST_TAG} | cut -d'.' -f 3 | cut -d'-' -f 1) && \
    wget https://github.com/Azure/azure-functions-host/archive/${HOST_TAG}.tar.gz && \
    tar xvzf ${HOST_TAG}.tar.gz && \
    cd azure-functions-host-* && \
    dotnet build /p:BuildNumber="$BUILD_NUMBER" WebJobs.Script.sln && \
    dotnet publish /p:BuildNumber="$BUILD_NUMBER" src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-bionic-arm32v7
ARG HOST_TAG

COPY --from=host-build-env ["/azure-functions-host", "/azure-functions-host"]

COPY ["libgrpc_csharp_ext.so", "/azure-functions-host/libgrpc_csharp_ext.so"]
COPY ["libgrpc_csharp_ext.so", "/azure-functions-host/libgrpc_csharp_ext.x86.so"]

RUN mkdir -p /home/site/wwwroot

ENV AzureWebJobsScriptRoot=/home/site/wwwroot


ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

CMD ["dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll"]
