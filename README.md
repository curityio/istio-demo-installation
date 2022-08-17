# Curity Identity Server in an Istio Cluster

## Prerequisites

- Install [Kubernetes in Docker (KIND)](https://kind.sigs.k8s.io/docs/user/quick-start/) for a Kubernetes development setup

Also download a license file for the Curity Identity Server and copy it into the `idsvr` folder.

## Deploy the System

Run these scripts to create some self signed ingress certificates and to spin up the cluster:

```bash
./create-cluster.sh
./create-certs.sh
./deploy-postgres.sh
./deploy-idsvr.sh
```

Then edit the /etc/hosts file and add the following entries:

```bash
127.0.0.1  admin.example.com login.example.com
```

Also add the following root certificate to your system's certificate trust store:

```text
certs/curity.local.ca.pem
```

## Use the System

Once complete you will have a fully working system:

- [OAuth and OpenID Connect Endpoints](https://login.curity.local/oauth/v2/oauth-anonymous/.well-known/openid-configuration) used by applications
- A rich [Admin UI](https://admin.curity.local/admin) for configuring applications and their security behavior
- A SQL database from which users, tokens, sessions and audit information can be queried
- A [SCIM 2.0 API](https://login.curity.local/user-management/admin) for managing user accounts
- A working [End to End Code Sample](https://login.curity.local/demo-client.html)

## Understand Namespaces

The Curity Identity Server is deployed to a `curity` namespace, which does not use sidecars.\
The Istio ingress gateway is used to expose the Curity Identity Server's admin and runtime nodes.\
Components that use Istio sidecars and Mutual TLS should be deployed to a separate namespace.

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.