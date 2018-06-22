ARG HOST_TAG=dev
FROM microsoft/dotnet:2.1-sdk AS installer-env
ARG HOST_TAG

ENV PublishWithAspNetCoreTargetManifest false

RUN if [ "${HOST_TAG}" = "dev" ]; \
    then export BUILD_NUMBER=00001; \
    else export BUILD_NUMBER=$(echo ${HOST_TAG} | cut -d'.' -f 3 | cut -d'-' -f 1); \
    fi && \
    echo "Build Number == $BUILD_NUMBER" &&\
    wget https://github.com/Azure/azure-functions-host/archive/${HOST_TAG}.tar.gz && \
    tar xvzf ${HOST_TAG}.tar.gz && \
    cd azure-functions-host-* && \
    dotnet build /p:BuildNumber="$BUILD_NUMBER" WebJobs.Script.sln && \
    dotnet publish /p:BuildNumber="$BUILD_NUMBER"  src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host

# Runtime image
FROM microsoft/dotnet:2.1-aspnetcore-runtime

COPY --from=installer-env ["/azure-functions-host", "/azure-functions-host"]

ENV AzureWebJobsScriptRoot=/home/site/wwwroot
ENV HOME=/home
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

CMD ["dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll"]
