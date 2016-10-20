# bradbeck/nexus-https

A Dockerfile for Sonatype Nexus Repository Manager 3 with HTTPS support, based on CentOS.

GitHub Repository: https://github.com/bradbeck/nexus-https

This Dockerfile is loosely base on the following, please refer to it for additional configuration information: https://github.com/sonatype/docker-nexus3

To run, binding the exposed ports (8081, 8443), exposed data directory, and exposed volume containing `keystore.jks`.

```
$ docker run -d -p 8081:8081 -p 8443:8443 -v ~/nexus-data:/opt/sonatype/sonatype-work/nexus3 -v ~/nexus-ssl:/opt/sonatype/nexus/etc/ssl --name nexus bradbeck/nexus-https
```

To (re)build the image:

```
$ docker build --rm --tag=bradbeck/nexus-https .
```


## Notes

* Default credentials are: `admin` / `admin123`

* Installation of Nexus is to `/opt/sonatype/nexus`.

* Nexus will expect to find a java keystore file at `/opt/sonatype/nexus/etc/ssl/keystore.jks` which
resides in the exposed volume `/opt/sonatype/nexus/etc/ssl`.

* A persistent directory, `/opt/sonatype/sonatype-work/nexus3`, is used for configuration,
logs, and storage. This directory needs to be writable by the Nexus
process, which runs as UID 200.
