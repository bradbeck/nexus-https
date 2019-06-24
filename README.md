[![DockerHub Badge](http://dockeri.co/image/bradbeck/nexus-https)](https://hub.docker.com/r/bradbeck/nexus-https/)

A Dockerfile for Sonatype Nexus Repository Manager 3 with HTTPS support, based on CentOS.

GitHub Repository: https://github.com/bradbeck/nexus-https

This Dockerfile is loosely based on the following, please refer to it for additional configuration information: https://github.com/sonatype/docker-nexus3

To run, generating a default `keystore.jks`.

```
docker run -p 8443:8443 bradbeck/nexus-https
```

To run, binding the exposed ports (8081, 8443), data directory, and volume containing `keystore.jks`.

```
$ docker run -d -p 8081:8081 -p 8443:8443 -v ~/nexus-data:/nexus-data -v ~/nexus-ssl:/opt/sonatype/nexus/etc/ssl --name nexus bradbeck/nexus-https
```

To (re)build the image:

```
$ docker build --rm --tag=bradbeck/nexus-https .
```
## Environment Variables
Variable               | Default Value | Description
-----------------------|----------------------------------------|------------
`PUBLIC_CERT`          |`/opt/sonatype/nexus/etc/ssl/cacert.pem`|the fully qualified container path for the CA certificate
`PUBLIC_CERT_SUBJ`     |`/CN=localhost`                         |the subject used if the CA certificate is created
`PRIVATE_KEY`          |`/opt/sonatype/nexus/etc/ssl/cakey.pem` |the fully qualified container path for the private certificate key
`PRIVATE_KEY_PASSWORD` |`password`                  |the password for the private certificate key, used for `keystore.jks` if it is being generated

## Notes

* Default credentials are: `admin` / `admin123`

* Installation of Nexus is to `/opt/sonatype/nexus`.

* Nexus will expect to find a java keystore file at `/opt/sonatype/nexus/etc/ssl/keystore.jks` which
resides in the exposed volume `/opt/sonatype/nexus/etc/ssl`.
  * `entrypoint.sh` will create `keystore.jks` if it does not already exist.

* A persistent directory, `/nexus-data`, is used for configuration,
logs, and storage. This directory needs to be writable by the Nexus
process, which runs as UID 200.
