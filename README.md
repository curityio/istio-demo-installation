# Curity Identity Server in an Istio Cluster

## Prerequisites

- Install [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/docs/user/quick-start/) for a Kubernetes development setup
- Also download a license.json file for the Curity Identity Server and copy it into the `idsvr` folder

## Deploy the System

Run these scripts in sequence to deploy the cluster and its components:

```bash
./create-cluster.sh
./create-external-certs.sh
./deploy-postgres.sh
./deploy-idsvr.sh
```

Then edit the /etc/hosts file and add the following entries:

```bash
127.0.0.1  login.curity.local admin.curity.local
```

Also add the following root certificate to your system's certificate trust store:

```text
certs/curity.external.ca.pem
```

## Run a Demo Application

The deployment includes a simple web client, using the hypermedia authentication API.\
Run it using the following details:

- URL: https://login.curity.local/demo-client.html
- User: john.doe
- Password: Password1

## Diagnose mTLS Requests

Run a utility pod that runs in an applications namespace that uses sidecars and mTLS:

```bash
./deploy-curl.sh
```

Open a terminal window, then run this command to eavesdrop traffic sent from the curl client pod:

```bash
kubectl -n applications exec curlclient -c istio-proxy \
-- sudo tcpdump -l --immediate-mode -vv -s 0
```

Then open a terminal in a client pod:

```bash
kubectl -n applications exec -it curlclient -- bash
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
