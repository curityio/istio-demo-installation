## Overview

The following areas are either problems or areas that I need to understand better.

## 1. Missing Runtine Node within the Admin UI

I need to look deeper into [Curity Cluster Configuration](https://curity.io/resources/learn/intro-to-cluster/).\
My main problem seems to be that runtime nodes cannot connect over port 6789 to the admin node.\
Runtime sidecar components are both showing response codes 'UF' related to port 6789:

- Failed to connect to upstream

## 2. SSL Trust

I don't think this is the cause, since the admin node shows a valid certificate.\
The runtime node does not however, suggesting that it perhaps needs to download it over port 6789.

- openssl s_client -connect curity-idsvr-admin-svc:6749
- openssl s_client -connect curity-idsvr-admin-svc:6789
- openssl s_client -connect curity-idsvr-runtime-svc:8443

I need to better understand exact details of how the default Curity SSL certificate is generated and trusted.
Using `curl -v\ shows that this file is used for SSL trust and that TLS 1.3 is used.

* /etc/ssl/certs/ca-certificates.crt

I think some customers will want to use volume mounts to pick up [cert-manager](https://github.com/jetstack/cert-manager) issued certificates.

## 3. Inter Container Calls

Calling admin HTTP endpoints sometimes results in this error:

- curl -k -u 'admin:Password1' 'https://curity-idsvr-admin-svc:6749/admin/api/restconf/data?depth=unbounded&content=config'
- curl: (35) error:1408F10B:SSL routines:ssl3_get_record:wrong version number

Calling runtime HTTP endpoints always results in this error.\
Note that calling port 6789 on the admin node also produces this error.

- curl -k 'https://curity-idsvr-runtime-svc:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration'
- curl: (35) OpenSSL SSL_connect: SSL_ERROR_SYSCALL in connection to curity-idsvr-runtime-svc:8443

Since the runtime node is not contactable internally, the ingress to https://login.example.com also fails:

- upstream connect error or disconnect/reset before headers. reset reason: connection failure

## 4. Possible DNS / Port Conflicts

It is possible that some of my entries conflict with each other in terms of DNS.\
Initially I used a different gateway for each subdomain but this also had problems.

https://github.com/istio/istio/issues/16531

## UPDATE

Issue with POD:
https://github.com/istio/istio/issues/14942