ARG HOST_COMMIT=dev
ARG BUILD_NUMBER=00001
FROM microsoft/dotnet:2.1-sdk AS installer-env
ARG HOST_COMMIT
ARG BUILD_NUMBER

ENV PublishWithAspNetCoreTargetManifest false

RUN export ARG_BUILD_NUMBER=${BUILD_NUMBER} && \
    if [ $ARG_BUILD_NUMBER = dev* ]; \
    then export SCRIPT_BUILD_NUMBER=00001; \
    else export SCRIPT_BUILD_NUMBER=$(echo $ARG_BUILD_NUMBER | cut -d'.' -f 3 | cut -d'-' -f 1); \
    fi && \
    echo "Build Number == $SCRIPT_BUILD_NUMBER" &&\
    wget https://github.com/Azure/azure-functions-host/archive/${HOST_COMMIT}.tar.gz && \
    tar xzf ${HOST_COMMIT}.tar.gz && \
    cd azure-functions-host-* && \
    dotnet publish /p:BuildNumber="$SCRIPT_BUILD_NUMBER" /p:CommitHash=${HOST_COMMIT} src/WebJobs.Script.WebHost/WebJobs.Script.WebHost.csproj --output /azure-functions-host

# Building GRPC takes about an hour. I build it once using the image under \grpc\stretch\arm32v7\Dockerfile
# and use the artifact from there everytime.
RUN apt-get update && apt-get install -y wget && \
    wget https://functionsbay.blob.core.windows.net/public/dependencies/grpc/arm32v7/libgrpc_csharp_ext.so.1.12.1 && \
    grpc_sha256='1483518b89c340b4baf766a150f33e68bb5af3f18b84680cca6b8a8d0ae0edcd' && \
    sha256sum libgrpc_csharp_ext.so.1.12.1 && \
    echo "$grpc_sha256 libgrpc_csharp_ext.so.1.12.1" | sha256sum -c -

# Runtime image
FROM microsoft/dotnet:2.1-aspnetcore-runtime-stretch-slim-arm32v7

COPY ./qemu-arm-static /usr/bin

COPY --from=installer-env ["/azure-functions-host", "/azure-functions-host"]
COPY --from=installer-env ["/libgrpc_csharp_ext.so.1.12.1", "/"]

RUN rm -f /azure-functions-host/runtimes/linux/native/* && \
    mv libgrpc_csharp_ext.so.1.12.1 /azure-functions-host/runtimes/linux/native/ && \
    cd /azure-functions-host/runtimes/linux/native/ && \
    ln -s libgrpc_csharp_ext.so.1.12.1 libgrpc_csharp_ext.so && \
    ln -s libgrpc_csharp_ext.so.1.12.1 libgrpc_csharp_ext.x64.so && \
    ln -s libgrpc_csharp_ext.so.1.12.1 libgrpc_csharp_ext.x86.so && \
    ln -s libgrpc_csharp_ext.so.1.12.1 libgrpc_csharp_ext.arm32v7.so

RUN mkdir -p /home/site/wwwroot

ENV AzureWebJobsScriptRoot=/home/site/wwwroot
ENV HOME=/home
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

RUN rm /usr/bin/qemu-arm-static

CMD ["dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll"]