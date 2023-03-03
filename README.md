# Curity Identity Server in an Istio Cluster

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

A deployment code example where the Curity Identity Server runs in an Istio sidecar.\
This provides a deployment option where you do not need to configure SSL certificates.\
The platform then ensures that mutual TLS is used, for OAuth requests inside the cluster.

## Cloud Deployments

This is a development setup, but the Istio behaviors can be easily adapted to any cloud system.\
To do so, follow one of the following tutorials to update the resources in the `cluster` folder:

- [Deploy to Google Kubernetes Engine (GKE)](https://curity.io/resources/learn/kubernetes-gke-idsvr-kong-phantom/)
- [https://curity.io/resources/learn/kubernetes-aws-eks-idsvr-deployment/](https://curity.io/resources/learn/kubernetes-aws-eks-idsvr-deployment/)
- [Deploy to Azure Kubernetes Service (AKS)](https://curity.io/resources/learn/kubernetes-azure-aks-idsvr-deployment/)

## Prerequisites

To deploy the development example, ensure that these tools are installed on your local computer:

- [Docker](https://www.docker.com/products/docker-desktop)
- [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Helm](https://helm.sh/docs/intro/install/)
- [openssl](https://www.openssl.org/)
- [envsubst](https://github.com/a8m/envsubst)

## Deploy the System

First, create cryptographic keys for the Curity Identity Server.\
This includes external ingress SSL certificates for the local development system:

```bash
./crypto.sh
```

Copy a license file into the `idsvr` folder and then run the main install:

```bash
./install.sh
```

Then edit the `/etc/hosts` file and add the following entries:

```bash
127.0.0.1  login.curity.local admin.curity.local
```

Also add the following external root certificate to your system's certificate trust store:

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

## Run OAuth Requests Inside the Cluster

Deploy the [Istio httpbin example](https://github.com/istio/istio/blob/master/samples/httpbin/httpbin.yaml) as an example microservice:

```bash
./microservice/install.sh
```

Get a shell in the microservice pod:

```bash
SERVICE_POD="$(kubectl -n applications get pod -o name)"
kubectl -n applications exec -it $SERVICE_POD -- sh
```

Call the Curity Identity Server with an internal OAuth request that uses mutual TLS:

```bash
curl http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-anonymous/jwks
```

To see how the microservice connects to the Curity Identity Server, run this command.\
The Istio sidecar deals with the mutual TLS details of the connection:

```bash
kubectl -n applications exec $SERVICE_POD -c istio-proxy \
     -- openssl s_client -showcerts \
     -connect curity-idsvr-runtime-svc.curity:8443 \
     -CAfile /var/run/secrets/istio/root-cert.pem | \
     openssl x509 -in /dev/stdin -text -noout
```

The response shows the X509 issued identity for runtime nodes of the Curity Identity Server:

```text
X509v3 Subject Alternative Name: 
  URI:spiffe://cluster.local/ns/curity/sa/curity-idsvr-service-account
```

## More Information

- See the [Istio Tutorial](https://curity.io/resources/learn/istio-demo-installation) on the Curity website for further details about this deployment.
- Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
