FROM sonatype/nexus3

LABEL maintainer="Brad Beck <bradley.beck+docker@gmail.com>"

ENV NEXUS_SSL=${NEXUS_HOME}/etc/ssl
ENV PUBLIC_CERT=${NEXUS_SSL}/cacert.pem \
    PUBLIC_CERT_SUBJ=/CN=localhost \
    PRIVATE_KEY=${NEXUS_SSL}/cakey.pem \
    PRIVATE_KEY_PASSWORD=password

ARG GOSU_VERSION=1.16

USER root

RUN set -eux; \
    microdnf install -y \
        openssl \
        libxml2 \
        libxslt \
    ; \
    microdnf clean all

RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
        aarch64) gosuArch='arm64' ;; \
    x86_64) gosuArch='amd64' ;; \
    *) echo >&2 "error: unsupported architecture: '$arch'"; exit 1 ;; \
    esac; \
    curl -fL -o /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$gosuArch.asc"; \
    curl -fL -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$gosuArch"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

RUN sed \
    -e '/^nexus-args/ s:$:,${jetty.etc}/jetty-https.xml:' \
    -e '/^application-port/a \
application-port-ssl=8443\
' \
    -i ${NEXUS_HOME}/etc/nexus-default.properties

COPY entrypoint.sh ${NEXUS_HOME}/entrypoint.sh
RUN chown nexus:nexus ${NEXUS_HOME}/entrypoint.sh && chmod a+x ${NEXUS_HOME}/entrypoint.sh

VOLUME [ "${NEXUS_SSL}" ]

EXPOSE 8443
WORKDIR ${NEXUS_HOME}

ENTRYPOINT [ "./entrypoint.sh" ]

CMD [ "bin/nexus", "run" ]
