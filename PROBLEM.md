## Overview

My main problem is around SSL connections inside the cluster

## Intermittent SSL Connection Errors

Admin HTTP endpoints:

- curl: (35) error:1408F10B:SSL routines:ssl3_get_record:wrong version number

Runtime HTTP endpoints:

- curl: (35) OpenSSL SSL_connect: SSL_ERROR_SYSCALL in connection to curity-idsvr-runtime-svc:8443

Runtime Ingress:

- upstream connect error or disconnect/reset before headers. reset reason: connection failure

The primary problem is that I cannot reach the runtime node:

- curl with --http1.1 or --http2 both fail
- from the -v option I see that TLS1.3 is used

Can I make TLS1.2 be used?

### OpenSsl Tracing

External certificates look OK:

openssl s_client -connect admin.example.com:443
openssl s_client -connect login.example.com:443

SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : 0000
    Session-ID: 
    Session-ID-ctx: 
    Master-Key: 
    Start Time: 1619520300
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)

openssl s_client -connect admin.example.com:443

- Returns no data

openssl s_client -connect login.example.com:443

- Connects but also displays this:\
  140097359830344:error:1408F10B:SSL routines:ssl3_get_record:wrong version number:ssl/record/ssl3_record.c:331:

Certificate verify location:

- /etc/ssl/certs/ca-certificates.crt

The issue may not be SSL trust and may instead be proxy or DNS related.\
It can be worked around using the inject=false annotation on the admin node but I want to avoid that.

- https://github.com/istio/istio/issues/16531

## LATEST

Remember minikube tunnel

Call port 6789 instead of the correct value of 6749 also produces this:

OpenSSL SSL_connect: SSL_ERROR_SYSCALL in connection to curity-idsvr-admin-svc:6789 

Admin and Runtime sidecar components are both showing response codes 'UF' related to port 6789:

- Failed to connect to upstream

In the Curity virtual service files these options seem to work best:

- hosts: "*" - makes login.example.com work in a browser
- port / number - makes admin.example.com work I think

Remote to the sidecar - write this up:

- kubectl exec -it pod/curity-idsvr-runtime-69dfc5b8b8-ctv2g -c istio-proxy -- bash

Both of these indicate OK:

- openssl s_client -connect curity-idsvr-admin-svc:6749
- openssl s_client -connect curity-idsvr-admin-svc:6789

-----BEGIN CERTIFICATE-----
MIIDqjCCApKgAwIBAgIEUT0v2zANBgkqhkiG9w0BAQsFADBMMQswCQYDVQQGEwJz
ZTEPMA0GA1UEChMGY3VyaXR5MSwwKgYDVQQDEyNjdXJpdHktaWRzdnItYWRtaW4t
NjZmYjZkOTg3Zi14enB4NTAeFw0yMTA0MjcxNTU3MTFaFw0yNjA0MjYxNTU3MTFa
MEwxCzAJBgNVBAYTAnNlMQ8wDQYDVQQKEwZjdXJpdHkxLDAqBgNVBAMTI2N1cml0
eS1pZHN2ci1hZG1pbi02NmZiNmQ5ODdmLXh6cHg1MIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEAntBAG+uj1J3LilKnDxUH5vfE5XaRKoV5WMLqr97+pSMG
+IZUpKHH8xzwntzMTtXXwfZMtAzAoHGdb5q7akDCY9GERJFp5nrYtkEAzlobftry
OvmbzaK7ze5TZ9ZjLm5aeO5NkPlJGdKMRCGZV3jfNbxp26eahBLuSrVcBRFxlV+l
c7n9nRycF9yTqvRTutAvMOVIAU/wiHoid2axkuYChHSx3+PbxkmL88VxqTVEg3Z0
AkJBPHCW+qKJt1aToihvDrXa6H0ITk5+hnAR50FL1KWCaHwDlMzGzgnjpXjJt+f4
o7N12k9t9q0tfF/kX2eH4f4U927pqf937CTtgYImAwIDAQABo4GTMIGQMAwGA1Ud
EwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwEwCwYDVR0PBAQDAgXgMD8GA1Ud
EQQ4MDaCI2N1cml0eS1pZHN2ci1hZG1pbi02NmZiNmQ5ODdmLXh6cHg1gglsb2Nh
bGhvc3SHBH8AAAEwHQYDVR0OBBYEFFvlj+RD8B8BZMPnLMjYTALcNV3kMA0GCSqG
SIb3DQEBCwUAA4IBAQB6cBYfxgpRMf7uQaQJe+Tckei1DrPgRrmAusGSsY3ubsHc
J4DrvhLXHi9Q/DicuE6CgY8m325TFhltDJIZOvry0CHMj8WQ6xMPMh9Bk3O5d/l6
lpdQS9CM9EDOcOUYrJ7g7uTpyzLLf4dZdTgXW2DHf8PT5FmlRVDDxT22Qg68Usqn
SusK0rlIeLn3Ogy0zOVOrRegZibFC0okLkIkgmLYHV79cVGQl4OhiocBIHakcfS8
LqEISGaXBWl+idTRd+O8v8AHLf6ff3y8AbSbe8Q3TszC8G8JlrvtbVubEqxHJT1d
o1v5fWRxohU9H2Sbe/1XiPsw0J8AtDRfN/D1CiKT
-----END CERTIFICATE-----

But no connection to runtime nodes:

- openssl s_client -connect curity-idsvr-runtime-svc:8443