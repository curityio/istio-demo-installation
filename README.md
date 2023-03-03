# Curity Identity Server in an Istio Service Mesh

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

A deployment code example where the Curity Identity Server runs in an Istio sidecar.\
This provides a deployment option where no internal SSL certificates are needed.\
The platform then ensures that mutual TLS is used, for OAuth requests inside the cluster.

## Cloud Deployments

This is a development setup, but the Istio behaviors can be easily adapted to any cloud system.\
To do so, follow one of the following tutorials to update the resources in the `cluster` folder:

- [Deploy to Google Kubernetes Engine (GKE)](https://curity.io/resources/learn/kubernetes-gke-idsvr-kong-phantom/)
- [Deploy to Elastic Kubernetes Service (EKS)](https://curity.io/resources/learn/kubernetes-aws-eks-idsvr-deployment/)
- [Deploy to Azure Kubernetes Service (AKS)](https://curity.io/resources/learn/kubernetes-azure-aks-idsvr-deployment/)

## Prerequisites

To deploy the development example, ensure that these tools are installed on your local computer:

- [Docker](https://www.docker.com/products/docker-desktop)
- [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Helm](https://helm.sh/docs/intro/install/)
- [openssl](https://www.openssl.org/)

## Deploy the System

Run the install script to create the cluster and deploy components:

```bash
./install.sh
```

Then edit the `/etc/hosts` file and add the following entries:

```bash
127.0.0.1  login.curity.local admin.curity.local
```

Also add the following external root certificate to your system's certificate trust store:

```text
./cluster/ingress-certificates/curity.external.ca.pem
```

Later, when you are finished testing, tear down the cluster with this command:

```bash
./uninstall.sh
```

## Use the Admin UI

Once deployment has completed, login to the Admin UI and complete the initial setup wizard:

- URL: https://admin.curity.local/admin
- User: admin
- Password: Password1

## Run OAuth Requests Inside the Cluster

The deployment also includes the [Istio httpbin example](https://github.com/istio/istio/blob/master/samples/httpbin/httpbin.yaml), to act as a microservice pod:

```bash
SERVICE_POD="$(kubectl -n applications get pod -o name)"
```

Call the Curity Identity Server with an internal OAuth request that uses mutual TLS.\
Note that the microservices uses plain HTTP URLs:

```bash
kubectl -n applications exec $SERVICE_POD -- \
  curl -s http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-anonymous/jwks
```

Run this command to see how the Istio sidecar upgrades the connection to use mutual TLS:

```bash
kubectl -n applications exec $SERVICE_POD -c istio-proxy \
     -- openssl s_client -showcerts \
     -connect curity-idsvr-runtime-svc.curity:8443 \
     -CAfile /var/run/secrets/istio/root-cert.pem | \
     openssl x509 -in /dev/stdin -text -noout
```

The response includes the SPIFFE identity for runtime nodes of the Curity Identity Server:

```text
X509v3 Subject Alternative Name: 
  URI:spiffe://cluster.local/ns/curity/sa/curity-idsvr-service-account
```

## More Information

- See the [Istio Tutorial](https://curity.io/resources/learn/istio-demo-installation) on the Curity website for further details about this deployment.
- Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
