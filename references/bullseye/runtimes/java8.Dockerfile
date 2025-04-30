# Build the runtime from source
ARG JAVA_VERSION=8u392b08
ARG JDK_NAME=jdk8u392-b08
ARG JAVA_HOME=/usr/lib/jvm/adoptium-8-x64
ARG HOST_WORKER_IMAGE
ARG HOST_BASE_IMAGE

FROM ${HOST_WORKER_IMAGE} AS workerImage-dotnet8
FROM ${HOST_BASE_IMAGE} AS linuxdedicatedbullseye-runtime
ARG HOST_VERSION
ARG JAVA_VERSION
ARG JAVA_HOME
ARG JDK_NAME

ENV FUNCTIONS_WORKER_RUNTIME=java \
    JAVA_HOME=${JAVA_HOME}

# Fix from https://github.com/AdoptOpenJDK/blog/blob/ba5844ddc0b7e25d8ae49ac65a8b4e25dea5a48c/content/blog/prerequisites-for-font-support-in-adoptopenjdk/index.md#linux
RUN apt-get update && \
    apt-get install -y libfreetype6 fontconfig fonts-dejavu && \
    apt-get install -y wget

RUN wget https://github.com/adoptium/temurin8-binaries/releases/download/${JDK_NAME}/OpenJDK8U-jdk_x64_linux_hotspot_${JAVA_VERSION}.tar.gz && \
    mkdir -p ${JAVA_HOME} && \
    tar -xzf OpenJDK8U-jdk_x64_linux_hotspot_${JAVA_VERSION}.tar.gz -C ${JAVA_HOME} --strip-components=1 && \
    rm -f OpenJDK8U-jdk_x64_linux_hotspot_${JAVA_VERSION}.tar.gz

COPY --from=workerImage-dotnet8 [ "/workers/java", "/azure-functions-host/workers/java" ]
#COPY --from=workerImage-dotnet8 [ "/usr/share/dotnet", "/usr/share/dotnet" ]

CMD [ "/opt/startup/start_nonappservice.sh" ]