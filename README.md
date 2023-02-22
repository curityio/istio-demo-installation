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
./deploy-httpbin.sh
```

Then edit the /etc/hosts file and add the following entries:

```bash
127.0.0.1  login.curity.local admin.curity.local
```

Also add the following root certificate to your system's certificate trust store:

```text
certs/curity.external.ca.pem
```

## Use the System

TODO

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
