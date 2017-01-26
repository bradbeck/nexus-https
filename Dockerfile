FROM       centos:centos7
MAINTAINER Brad Beck <bradley.beck+docker@gmail.com>

ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_DIR=${SONATYPE_DIR}/nexus \
    SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work
ENV EXTRA_JAVA_OPTS='' \
    JAVA_HOME=/opt/java \
    JAVA_MAX_MEM=1200m \
    JAVA_MIN_MEM=1200m \
    JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=121 \
    JAVA_VERSION_BUILD=13 \
    JAVA_VERSION_HASH=e9e7ea248e2c4826b92b3f075a80e441 \
    NEXUS_CONTEXT='' \
    NEXUS_DATA=/nexus-data \
    NEXUS_SSL=${NEXUS_DIR}/etc/ssl

RUN yum install -y curl tar \
  && yum clean all

# install Oracle JRE
RUN mkdir -p /opt \
  && curl --fail --silent --location --retry 3 \
    --header "Cookie: oraclelicense=accept-securebackup-cookie; " \
    http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_VERSION_HASH}/server-jre-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
  | gunzip \
  | tar -x -C /opt \
  && ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} ${JAVA_HOME}

ARG NEXUS_VERSION=3.2.0-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

# install nexus
RUN mkdir -p ${NEXUS_DIR} \
  && curl --fail --silent --location --retry 3 \
    ${NEXUS_DOWNLOAD_URL} \
  | gunzip \
  | tar x -C ${NEXUS_DIR} --strip-components=1 nexus-${NEXUS_VERSION} \
  && chown -R root:root ${NEXUS_DIR}

RUN sed \
    -e '/^nexus-args/ s:$:,${jetty.etc}/jetty-https.xml:' \
    -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' \
    -e '/^application-port/a \
application-port-ssl=8443\
' \
    -i ${NEXUS_DIR}/etc/nexus-default.properties

RUN mkdir -p ${SONATYPE_WORK} \
  && useradd -r -u 200 -m -c "nexus role account" -d ${NEXUS_DATA} -s /bin/false nexus \
  && ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3

VOLUME ["${NEXUS_DATA}", "${NEXUS_SSL}"]

EXPOSE 8081 8443
USER nexus
WORKDIR ${NEXUS_DIR}

CMD ["bin/nexus", "run"]
