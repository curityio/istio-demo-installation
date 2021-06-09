## Overview

A small repo for running an End to End Solution on a MacBook with Istio and the Curity Identity Server.\
This is meant to provide a more `Real World Developer Setup` that also educates the user.

## Prerequisites

Install Docker for MacOS if required, then install Minikube as a local Kubernetes cluster.\
Also install the [yq tool](https://github.com/mikefarah/yq), used to automate some updates to Kubernetes files.

- brew update
- brew install minikube
- minikube config set driver hyperkit
- brew install helm
- brew install yq

Also copy a license file into the idsvr folder, to prevent startup errors.

## Cluster Base Setup

Run these scripts to create some self signed ingress certificates and to spin up the cluster:

- ./create-certs.sh
- ./create-cluster.sh

Then view some overview details of the Istio system:

- kubectl get all -n istio-system
- kubectl -n istio-system describe service istio-ingressgateway

Then add `~/istio-1.10.0/bin` to your PATH environment variable in ~/.zprofile and restart the terminal.

## URL Setup

Run this command in a separate terminal, which provides an external IP address needed for ingress to work:

 - minikube tunnel --profile example

Then run this command and read the value of the EXTERNAL-IP field:

- kubectl get svc istio-ingressgateway -n istio-system

Then edit the `/etc/hosts` file and add entries like this, using the external IP address:

- 10.108.72.131 web.example.com
- 10.108.72.131 api.example.com
- 10.108.72.131 login.example.com 
- 10.108.72.131 admin.example.com 

Also add the root certificate at `certs/example.com.ca.pem` to Keychain Access under System/Certificates.\
This ensures that the wildcard certificate for the above domain names is trusted on your MacBook.

## Deploy a Minimal Web Component

To understand the basics of how Kubernetes and Istio work, run this script and read the YAML files referenced:

- ./deploy-webhost.sh

 Then browse to the web URL to see the component successfully render some trivial HTML:

- https://web.example.com

## View Sidecar Components

Note how the web host's pods now include a sidecar component called 'istio-proxy':

- POD=$(kubectl get pods -o name | grep webhost)
- kubectl describe $POD

This is because the create-cluster.sh script made Istio injection the default behavior:

- kubectl label namespace default istio-injection=enabled

Generally an Istio cluster can have a mix of Istio components and Non Istio components.\
Istio components use built in Mutual TLS when they call each other, but interop is also supported.

## Deploy the Curity Identity Server

Execute these commands to deploy a SQL database and the Identity Server to the cluster:

- ./deploy-mysql.sh
- ./deploy-idsvr.sh

Whether or not the Identity Server uses sidecar proxies is controlled by a USE_ISTIO_SIDECARS flag.\
This can be toggled within the deploy-idsvr.sh script.

## View Ingress Details

In an Istio cluster it is recommended to use Istio ingress components with additional capabilities.\
Components need to define Gateway / Virtual Service / Destination Rule objects:

- [Gateway](./base/gateway.yaml)
- [Virtual Services](./idsvr/virtualservices.yaml)
- [Destination Rules](./idsvr/destinationrules.yaml)

Extra resources can then be managed by the built in kubectl command:

- kubectl get gateway
- kubectl get virtualservice
- kubectl get destinationrule

## Use the Identity Server Externally

Browse to these working URLs:

- https://admin.example.com/admin
- https://login.example.com/oauth/v2/oauth-anonymous/.well-known/openid-configuration

Then run the HAAPI Web Sample and login using these credentials and the Safari browser:

- https://login.example.com/demo-client.html
- john.doe
- Password1

## Connect to the Identity Server Inside the Cluster

Start a shell to an Istio POD:

```bash
POD=$(kubectl get pods -o name | grep webhost)
kubectl exec -it $POD -- sh
```

Then test connectivity to the Curity Identity Server.\
The idea is to verify that customer APIs and other components using Istio sidecars could connect successfully.

```bash
curl -u 'admin:Password1' 'http://curity-idsvr-admin-svc:6749/admin/api/restconf/data?depth=unbounded&content=config'
curl 'http://curity-idsvr-runtime-svc:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration'
```