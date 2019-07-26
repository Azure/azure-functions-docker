FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS runtime-image

ENV PublishWithAspNetCoreTargetManifest=false
ENV HOST_VERSION=v2.0.12562
ENV HOST_COMMIT=557678059e699fc61f298d226ccd91c1302d1388

RUN apt-get update && \
    apt-get install -y unzip && \
    cp ${HOST_ARTIFACT_PATH} /azure-functions-host.zip && \
    unzip /azure-functions-host.zip -d /azure-functions-host -y && \
    rm -f /azure-functions-host.zip && \
    mv /azure-functions-host/workers /workers && mkdir /azure-functions-host/workers

FROM mcr.microsoft.com/dotnet/core/runtime-deps:2.2

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image ["/workers", "/workers"]

RUN apt-get update && \
    apt-get install -y gnupg wget unzip && \
    wget https://functionscdn.azureedge.net/public/ExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.0.0/Microsoft.Azure.Functions.ExtensionBundle.1.0.0.zip && \
    mkdir -p /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.0.0 && \
    unzip /Microsoft.Azure.Functions.ExtensionBundle.1.0.0.zip -d /FuncExtensionBundles/Microsoft.Azure.Functions.ExtensionBundle/1.0.0 && \
    rm -f /Microsoft.Azure.Functions.ExtensionBundle.1.0.0.zip

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]