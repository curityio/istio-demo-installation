# Curity Identity Server in an Istio Cluster

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

An example setup where the Curity Identity Server runs in an Istio sidecar.\
This provides a deployment option where you do not need to configure SSL certificates.\
The platform then ensures that mutual TLS is used, for OAuth requests inside the cluster.

## Prerequisites

- Install [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/docs/user/quick-start/) for a development setup
- Install the [jq](https://stedolan.github.io/jq/download/) tool
- Install the [envsubst](https://github.com/a8m/envsubst) tool

## Deploy the System

First create cryptographic keys and external SSL certificates:

```bash
./crypto.sh
```

Next run the installation, supplying the path to a license file for the Curity Identity Server:

```bash
export CURITY_LICENSE_FILE_PATH=~/Desktop/license.json
./install.sh
```

Then edit the `/etc/hosts` file and add the following entries:

```bash
127.0.0.1  login.curity.local admin.curity.local
```

Also add the following root certificate to your system's certificate trust store:

```text
./crypto/curity.external.ca.pem
```

When you are finished testing, tear down the cluster with this command:

```bash
./uninstall.sh
```

## Use the Admin UI

Once deployment has completed, login to the Admin UI with these details:

- URL: https://admin.curity.local/admin
- User: admin
- Password: Password1

## Run a Demo Application

A simple web client is also deployed, using the hypermedia authentication API.\
Run it using the following parameters:

- URL: https://login.curity.local/demo-client.html
- User: john.doe
- Password: Password1

## Diagnose mTLS Requests

Deploy some utility pods that use sidecars and mTLS, in an `applications` namespace:

```bash
./deploy-utils.sh
```

Next get a shell to the client pod:

```bash
CLIENT_POD="$(kubectl -n applications get pod -o name | grep sleep)"
kubectl -n applications exec -it $CLIENT_POD -- sh
```

From the client pod, make a `plain HTTP` call to an endpoint that returns API response headers:

```bash
curl http://httpbin:8000/headers
```

This header provides evidence that mTLS was used between sidecars.\
It also shows the `service workload identity` and `client workload identity`:

```text
X-Forwarded-Client-Cert: 
  By=spiffe://cluster.local/ns/applications/sa/httpbin; 
  Subject=spiffe://cluster.local/ns/applications/sa/sleep
```

Calls from APIs inside the cluster to the Curity Identity Server will work in an equivalent way:

```bash
curl http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-anonymous/jwks
```

To see the X509 certificate details, run this command from a terminal on the host computer:

```bash
SERVICE_POD="$(kubectl -n applications get pod -o name | grep httpbin)"
kubectl -n applications exec $SERVICE_POD -c istio-proxy \
     -- openssl s_client -showcerts \
     -connect curity-idsvr-runtime-svc.curity:8443 \
     -CAfile /var/run/secrets/istio/root-cert.pem | \
     openssl x509 -in /dev/stdin -text -noout
```

The response shows the X509 SVID for runtime nodes of the Curity Identity Server:

```text
X509v3 Subject Alternative Name: 
  URI:spiffe://cluster.local/ns/curity/sa/default
```

## More Information

- See the [Istio Tutorial](https://curity.io/resources/learn/istio-demo-installation) on the Curity website for further details about this deployment.
- Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
