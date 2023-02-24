# Curity Identity Server in an Istio Cluster

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
certs/curity.external.ca.pem
```

When you are finished testing, tear down the cluster with this command:

```bash
./uninstall.sh
```

## Run a Demo Application

The deployment includes a simple web client, using the hypermedia authentication API.\
Run it using the following parameters:

- URL: https://login.curity.local/demo-client.html
- User: john.doe
- Password: Password1

## Diagnose mTLS Requests

Get a shell to a utility pod that uses sidecars and mTLS and runs in an `applications` namespace:

```bash
./deploy-curl.sh
```

On the host, open a terminal window, then run this command to eavesdrop traffic sent from the curl client pod:

```bash
kubectl -n applications exec curlclient -c istio-proxy \
-- sudo tcpdump -l --immediate-mode -vv -s 0
```

Then call the Curity Identity Server, with a plain HTTP request:

```bash
curl http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration
```

If plain HTTP was used, the tcpdump would show cleartext, but the request actually uses SSL and mTLS.\
Run the following command to see how the proxy communicates with the target URL:

```bash
kubectl -n applications exec curlclient -c istio-proxy \
     -- openssl s_client -showcerts \
     -connect curity-idsvr-runtime-svc.curity:8443 \
     -CAfile /var/run/secrets/istio/root-cert.pem | \
     openssl x509 -in /dev/stdin -text -noout
```

The response shows how the connection uses SPIFFE mTLS certificate details:

```text
 X509v3 Subject Alternative Name: critical
  URI:spiffe://cluster.local/ns/curity/sa/default
```

## More Information

- See the [Istio Tutorial](https://curity.io/resources/learn/istio-demo-installation) on the Curity website for further details about this deployment.
- Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
