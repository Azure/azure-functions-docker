FROM debian:bullseye

ARG MAVEN_VERSION=3.8.4
ARG USER_HOME_DIR="/root"
ARG SHA=a9b2d825eacf2e771ed5d6b0e01398589ac1bfa4171f36154d1b5787879605507802f699da6f7cfc80732a5282fd31b28e4cd6052338cbef0fa1358b48a5e3c8
ARG BASE_MAVEN_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
ARG JAVA_VERSION=8u312b07
ARG JDK_NAME=jdk8u312-b07
ARG BASE_JDK_URL=https://github.com/adoptium/temurin8-binaries/releases/download/${JDK_NAME}
ARG JAVA_HOME=/usr/lib/jvm/adoptium-8-x64

RUN apt-get -qq update \
    && apt-get -qqy install curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_MAVEN_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

RUN mkdir -p ${JAVA_HOME} \
    && curl -fsSL -o /tmp/jdk.tar.gz ${BASE_JDK_URL}/OpenJDK8U-jdk_x64_linux_hotspot_${JAVA_VERSION}.tar.gz \
    && tar -xzf /tmp/jdk.tar.gz -C ${JAVA_HOME} --strip-components=1 \
    && rm -f /tmp/jdk.tar.gz

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
ENV JAVA_HOME=${JAVA_HOME}

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]