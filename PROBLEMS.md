## Overview

The following areas summarise problems with default behavior:

## Issue 1: Cluster Configuration

I experienced an error in the Cluster Conf Job due to the createConfigSecret openssl call failing.\
I think the cause was the openssl call being made too early, before the sidecar proxy was ready.\
It is resolved by overriding the default to avoid adding a sidecar to the job component:

- spec:
    template:
      metadata:
        annotations:
          sidecar.istio.io/inject: "false"

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