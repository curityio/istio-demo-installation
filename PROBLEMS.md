## Overview

The following areas summarise open issues to the best of my current understanding.

## Issue 1: Identity Server does not support Sidecar Proxies

An option in deploy-idsvr.sh can be used to deploy Identity Server with Istio sidecar proxies.\
The admin node deploys fine but the runtime node can never connect to the admin node.\
This seems to be related to use of port 6789 and a runtime Mutual TLS connection.

The admin node does not have a permanent TLS endpoint.\
This may conflict with Istio's default setup of Mutual TLS connections between sidecar proxies.\
Rules around TLS connections are a little tricky to understand and these are my current settings:

- [Identity Server Virtual Services](./idsvr/virtualservices.yaml)
- [Identity Server Destination Rules](./idsvr/destinationrules.yaml)

## Issue 2: POD Startup Times could be Improved

Java startup of the Curity Identity Server is fast and takes no more than around 20 seconds.\
Kubernetes cluster startup is slower than I'd expect though:

- I use an initialDelaySeconds of 120 and a lower value results in POD restarts

Using 'kubectl get pods --watch' then results in these startup times on my high spec MacBook:

- NAME                                    READY   STATUS              RESTARTS   AGE
- curity-idsvr-admin-bdfcc8f99-5sr6n      1/1     Running             0          2m27s
- curity-idsvr-runtime-559f9dc776-j4zgm   1/1     Running             0          2m31s
- curity-idsvr-runtime-559f9dc776-px7f6   1/1     Running             0          2m32s

On older hardware it is slower though and there may be some restarts.\
The calls from runtime to admin node output lots of errors during this stage.\
There may be some areas for improvement when running in Kubernetes.

## Issue 3: Configuration Data Behavior

This repository backs up configuration and SQL data via the [Backup Script](backup-data.sh).\
The script calls the REST API to download configuration, which has multiple formats:

```bash
# Download from Admin UI
<config xmlns="http:\/\/tail-f.com\/ns\/config\/1.0">

# Download via Admin REST API
<data xmlns="urn:ietf:params:xml:ns:yang:ietf-restconf">
```

The backed up configuration file is deployed via a ConfigMap to /opt/idsvr/etc/init/configmap-config.xml.\
If an XML file with the REST API format is used the container fails to start - is this expected behavior?
