FROM debian:buster

ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_MAVEN_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
ARG JAVA_VERSION=11.0.12.7.1
ARG BASE_JDK_URL=https://aka.ms/download-jdk
ARG JAVA_HOME=/usr/lib/jvm/msft-11-x64

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
    && curl -fsSL -o /tmp/jdk.tar.gz ${BASE_JDK_URL}/microsoft-jdk-${JAVA_VERSION}-linux-x64.tar.gz \
    && tar -xzf /tmp/jdk.tar.gz -C ${JAVA_HOME} --strip-components=1 \
    && rm -f /tmp/jdk.tar.gz

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
ENV JAVA_HOME=${JAVA_HOME}

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]