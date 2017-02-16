#!/usr/bin/env bash

set -x
set -eo pipefail

if [ "$1" == 'bin/nexus' ]; then
  if [ ! -f "$NEXUS_SSL/keystore.jks" ]; then
    mkdir -p $NEXUS_SSL
    if [ ! -f $PUBLIC_CERT ] && [ ! -f $PRIVATE_KEY ]; then
      openssl req -nodes -new -x509 -keyout $PRIVATE_KEY -out $PUBLIC_CERT -subj "${PUBLIC_CERT_SUBJ}"
    fi
    if [ ! -f $NEXUS_SSL/jetty.key ]; then
      openssl pkcs12 -export -in $PUBLIC_CERT -inkey $PRIVATE_KEY -out $NEXUS_SSL/jetty.key -passout pass:$PRIVATE_KEY_PASSWORD
    fi
    $JAVA_HOME/bin/keytool -importkeystore -noprompt -deststorepass $PRIVATE_KEY_PASSWORD -destkeypass $PRIVATE_KEY_PASSWORD -destkeystore $NEXUS_SSL/keystore.jks -srckeystore $NEXUS_SSL/jetty.key -srcstoretype PKCS12 -srcstorepass $PRIVATE_KEY_PASSWORD
    sed -r '/<Set name="(KeyStore|KeyManager|TrustStore)Password">/ s:>.*$:>'$PRIVATE_KEY_PASSWORD'</Set>:' -i $NEXUS_HOME/etc/jetty/jetty-https.xml
  fi

  mkdir -p "$NEXUS_DATA"
  chown -R nexus:nexus "$NEXUS_DATA"

  exec gosu nexus "$@"
fi

exec "$@"
