# Curity Identity Server in an Istio Cluster

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

An example development setup where the Curity Identity Server runs in an Istio sidecar.\
This provides a deployment option where you do not need to configure SSL certificates.\
The platform then ensures that mutual TLS is used, for OAuth requests inside the cluster.

## Prerequisites

First ensure that these tools are installed on your local computer:

- [Docker](https://www.docker.com/products/docker-desktop)
- [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Helm](https://helm.sh/docs/intro/install/)
- [openssl](https://www.openssl.org/)
- [envsubst](https://github.com/a8m/envsubst)

## Deploy the System

First create cryptographic keys fore the Curity Identity Server.\
This also creates external ingress SSL certificates for the local development system:

```bash
./crypto.sh
```

Copy a license file into the `idsvr` folder and then run the install:

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

## Run a Demo Application

A simple web client is also deployed, using the hypermedia authentication API.\
Run it using the following parameters:

- URL: https://login.curity.local/demo-client.html
- User: john.doe
- Password: Password1

## Run OAuth Requests Inside the Cluster



## More Information

- See the [Istio Tutorial](https://curity.io/resources/learn/istio-demo-installation) on the Curity website for further details about this deployment.
- Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
