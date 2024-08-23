FROM mcr.microsoft.com/dotnet/sdk:6.0 

ARG MAVEN_VERSION=3.8.5
ARG USER_HOME_DIR="/root"
ARG SHA=89ab8ece99292476447ef6a6800d9842bbb60787b9b8a45c103aa61d2f205a971d8c3ddfb8b03e514455b4173602bd015e82958c0b3ddc1728a57126f773c743
ARG BASE_MAVEN_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries
ARG JAVA_VERSION=17.0.9
ARG BASE_JDK_URL=https://aka.ms/download-jdk
ARG JAVA_HOME=/usr/lib/jvm/msft-17-x64

RUN apt-get -qq update \
    && apt-get -qqy install curl \
    && apt-get install -y libfreetype6 fontconfig fonts-dejavu \
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

RUN chmod +x /usr/local/bin/mvn-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]