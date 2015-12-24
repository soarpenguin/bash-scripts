#!/usr/bin/env bash

yum clean all
yum install -y docker-io.x86_64 --nogpgcheck

mkdir -p /opt/docker

cat > /etc/sysconfig/docker << EOF
# /etc/sysconfig/docker
#
# Other arguments to pass to the docker daemon process
# These will be parsed by the sysv initscript and appended
# to the arguments list passed to docker -d

other_args="-g /opt/docker -H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock --insecure-registry docker.registry.io "
DOCKER_CERT_PATH=/etc/docker

# Resolves: rhbz#1176302 (docker issue #407)
DOCKER_NOWARN_KERNEL_VERSION=1

# Location used for temporary files, such as those created by
# # docker load and build operations. Default is /var/lib/docker/tmp
# # Can be overriden by setting the following environment variable.
# # DOCKER_TMPDIR=/var/tmp
DOCKER_TMPDIR=/opt/docker/tmp
EOF


/etc/init.d/docker start

/sbin/chkconfig docker on

######### set docker privilege
update-ca-trust enable
cd /etc/pki/ca-trust/source/anchors/

cat > dockerCA.crt << EOF
-----BEGIN CERTIFICATE-----
MIIECzCCAvOgAwIBAgIJANsO8Y12smiJMA0GCSqGSIb3DQEBBQUAMIGbMQswCQYD
VQQGEwJDTjEQMA4GA1UECAwHQmVpamluZzEQMA4GA1UEBwwHQmVpamluZzEhMB8G
A1UECgwYcmVnaXN0cnkuY21kYi4xdmVyZ2UubmV0MSEwHwYDVQQDDBhyZWdpc3Ry
eS5jbWRiLjF2ZXJnZS5uZXQxIjAgBgkqhkiG9w0BCQEWE3podXllZmVuZ0B5b3Vr
dS5jb20wHhcNMTUxMTI1MDU0NzE0WhcNMjUxMTIyMDU0NzE0WjCBmzELMAkGA1UE
BhMCQ04xEDAOBgNVBAgMB0JlaWppbmcxEDAOBgNVBAcMB0JlaWppbmcxITAfBgNV
BAoMGHJlZ2lzdHJ5LmNtZGIuMXZlcmdlLm5ldDEhMB8GA1UEAwwYcmVnaXN0cnku
Y21kYi4xdmVyZ2UubmV0MSIwIAYJKoZIhvcNAQkBFhN6aHV5ZWZlbmdAeW91a3Uu
Y29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0rwfRo7XHxvHoc6p
EpYMks/3C4p3TNuJJ6Ihsrs0Z7gfSVV6HHfO8TQ6IUb7wSiax/OGKF1kBZq78No0
fR2bALyrCDqPhOkBMSxEcpTyDUEFW9eF6fSI3e63eUXb4kX0PwFMrPKu1benHo6k
RxPruxcYFAqOJtR+2vBybNtJtGfJLHYUwFxsf1Id181WTArZ0zs5mTQRmiXc6EiS
W33PfHjgjJiiEPao0abSIyHRjdQaySS8skbaiSnzh9RW4QOAupD8pRAcMmXzWA5g
gsYnXdKg6I23pp1yvz7BCLSHH/pdxdzKg9E24wIkgwNlmR6VhchPKWE+3erqqRic
VRXZMwIDAQABo1AwTjAdBgNVHQ4EFgQUJZhgtgg/a6Tx3w2Ri5gBqAh/cU0wHwYD
VR0jBBgwFoAUJZhgtgg/a6Tx3w2Ri5gBqAh/cU0wDAYDVR0TBAUwAwEB/zANBgkq
hkiG9w0BAQUFAAOCAQEAlzdkw39XPF8aWKlEDzfDiD7smJprVIg/fedpIb9rTGJz
e73mabtVu5RLbqVlcDZM23SFYH8tUF/SdSvhpzUW+C36QhPLSXZEVk8BBtUxYXd5
Xp/O2+O58hXbuaLy54vw7VxZWK7x2i4FyG41JXI55mnWhKd5QaIu+lIAtGqOsva+
Kld8hCsmVPWmcRnI8QxuKBqahWH+Q4tkr7hTU/vSadYsYRemz1BLhhaZS+uMR+gz
3i6smnAZlY84T5SUMYeNuDfR/rWNIzBl9RSsxfQ6riSauaPbmmWdWAVp0t+V0j9y
XTXLtmOWg8kJNG7BiNk6de6TYymzyYSPoL6CnpCfpg==
-----END CERTIFICATE-----
EOF

chmod 644 dockerCA.crt

mkdir -p /etc/docker/certs.d/docker.registry.io/
\cp dockerCA.crt /etc/docker/certs.d/docker.registry.io/ca.crt
update-ca-trust extract

docker login --username='soarpenguin' --password='abcd' --email="soarpenguin.com" https://docker.registry.io/v2/
