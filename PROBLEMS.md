## Overview

The following areas summarise problems with default behavior:

## Issue 1: Cluster Configuration

I experienced an error in the Cluster Conf Job due to the createConfigSecret openssl call failing:

- 139906036158912:error:0200206F:system library:connect:Connection refused:../crypto/bio/b_sock2.c:110:
- 139906036158912:error:2008A067:BIO routines:BIO_connect:connect error:../crypto/bio/b_sock2.c:111:
- connect:errno=111

I think the cause was the openssl call being made too early, before the sidecar proxy was ready.\
It is resolved by overriding the default to avoid adding a sidecar to the job component:

- spec:
    template:
      metadata:
        annotations:
          sidecar.istio.io/inject: "false"

- https://github.com/istio/istio/issues/11130
- https://stackoverflow.com/questions/59235887/how-to-disable-istio-on-k8s-job

## Issue 2: Slow POD Startup

Curity PODS take 5 to 10 minutes to reach a ready state and are quite a bit slower than usual.\
During this time the Istio sidecar is in a ready state but admin and runtime nodes are not.

## TODO



Minor things:

- Get HAAPI working
- YAML automated updates
- SQL updates and storage of john.doe user + password

Major thing:

Nodes take 10 minutes to reach a ready state due to calls from runtime to admin nodes over port 6789.\
This may be related to calls to port 6789 and the comments in [this file](./idsvr/virtualservices.yaml).