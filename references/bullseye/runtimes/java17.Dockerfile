# Build the runtime from source
ARG JAVA_VERSION=17.0.9
ARG JAVA_HOME=/usr/lib/jvm/msft-17-x64
ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE

FROM ${HOST_WORKER_IMAGE} AS workerImage-dotnet8
FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbullseye-runtime
ARG HOST_VERSION
ARG JAVA_VERSION
ARG JAVA_HOME

ENV FUNCTIONS_WORKER_RUNTIME=java \
    JAVA_HOME=${JAVA_HOME} \
    ASPNETCORE_URLS=http://+:80

# Fix from https://github.com/AdoptOpenJDK/blog/blob/ba5844ddc0b7e25d8ae49ac65a8b4e25dea5a48c/content/blog/prerequisites-for-font-support-in-adoptopenjdk/index.md#linux
RUN apt-get update && \
    apt-get install -y libfreetype6 fontconfig fonts-dejavu && \
    apt-get install -y wget

RUN wget https://aka.ms/download-jdk/microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz && \
    mkdir -p ${JAVA_HOME} && \
    tar -xzf microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz -C ${JAVA_HOME} --strip-components=1 && \
    rm -f microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz

COPY --from=workerImage-dotnet8 [ "/workers/java", "/azure-functions-host/workers/java" ]

CMD [ "/opt/startup/start_nonappservice.sh" ]