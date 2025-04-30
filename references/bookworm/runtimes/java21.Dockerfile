# Build the runtime from source
ARG JAVA_VERSION=21.0.1
ARG JAVA_HOME=/usr/lib/jvm/msft-21-x64
ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE

FROM ${HOST_WORKER_IMAGE} AS workerImage-dotnet8
FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbookworm-runtime
ARG JAVA_VERSION
ARG JAVA_HOME

# Fix from https://github.com/GoogleCloudPlatform/google-cloud-dotnet-powerpack/issues/22#issuecomment-729895157
RUN apt-get update && \
    apt-get install -y libc-dev && \
    apt-get install -y wget && \
    apt-get install -y libfreetype6 fontconfig fonts-dejavu

RUN wget https://aka.ms/download-jdk/microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz && \
    mkdir -p ${JAVA_HOME} && \
    tar -xzf microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz -C ${JAVA_HOME} --strip-components=1 && \
    rm -f microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz

ENV FUNCTIONS_WORKER_RUNTIME=java \
    JAVA_HOME=${JAVA_HOME} \
    ASPNETCORE_URLS=http://+:80

COPY --from=workerImage-dotnet8 [ "/workers/java", "/azure-functions-host/workers/java" ]

CMD [ "/opt/startup/start_nonappservice.sh" ]