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

## Issue 2: Slow POD Startup in an Istio Cluster

Curity PODS take around 10 minutes to reach a ready state, whether or not sidecar proxies are used.\
This needs to be better understood in terms of troubleshooting:

- 'kubectl logs' for the admin node shows that it soon starts listening on port 6749
- But the admin node does not reach a ready state for around 10 minutes
- During this period 'kubectl logs' shows that the runtime node is trying to connect

The diagnostics commands in the [Architecture Document](ARCHITECTURE.MD) do not explain the reasons why.\
This may need looking at in terms of Identity Server internals.

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
