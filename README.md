## Overview

A small repo for running an end to end solution on a MacBook with Istio and the Curity Identity Server

## Prerequisites

Install Docker for MacOS if required, then install Minikube as a local Kubernetes cluster.\
Also install the [yq tool](https://github.com/mikefarah/yq), used to automate some Kubernetes annotation updates.

- brew update
- brew install minikube
- minikube config set driver hyperkit
- brew install yq

## Cluster Base Setup

Run this script, and also read it to understand the setup:

- ./create-cluster.sh

Then view some overview details of the Istio system:

- kubectl get all -n istio-system
- kubectl -n istio-system describe service istio-ingressgateway

Then add `~/istio-1.9.3/bin` to your PATH environment variable in ~/.zprofile and restart the terminal.

## URL Setup

Run this command in a separate terminal, which provides an external IP address needed for ingress to work:

 - minikube tunnel --profile example

Then run this command and get the value of the EXTERNAL-IP field:

- kubectl get svc istio-ingressgateway -n istio-system

Then edit the `/etc/hosts` file and add entries like this, using the external IP address:

- 10.108.72.131 web.example.com
- 10.108.72.131 api.example.com
- 10.108.72.131 login.example.com 
- 10.108.72.131 admin.example.com 

Also add the root certificate at `certs/example.com.ca.pem` to Keychain Access under System/Certificates.\
This ensures that the wildcard certificate for the above domain names is trusted on your MacBook.

## Deploy a Minimal Web Component

To understand the basics of how Kubernetes and Istio work, run this script:

- ./deploy-webhost.sh

 Then browse to the web URL to see the component successfully render some HTML:

- https://web.example.com

## Deploy the Curity Identity Server

Execute these commands to deploy a SQL database and the Identity Server to the cluster:

- ./deploy-mysql.sh
- ./deploy-idsvr.sh

## View Sidecar Components

Note how all pods, including those for the Curity Identity Server, now include a sidecar component called 'istio-proxy':

- POD=$(kubectl get pods -o name | grep webhost)
- kubectl describe $POD

This is because the Create Cluster script made Istio injection the default behavior:

- kubectl label namespace default istio-injection=enabled

## View Ingress Details

Istio uses different ingress components with richer options than the base Kubernetes ingress.\
This includes use of Gateway / Virtual Service / Destination Rule components:

- [Gateway](./base/gateway.yaml)
- [Virtual Services](./idsvr/virtualservices.yaml)
- [Destination Rules](./idsvr/destinationrules.yaml)

Extra networking objects then become available for managing the cluster:

- kubectl get gateway
- kubectl get virtualservice
- kubectl get destinationrule

## Use the Identity Server Externally

Browse to these working URLs:

- https://admin.example.com/admin
- https://login.example.com/oauth/v2/oauth-anonymous/.well-known/openid-configuration

Then login using the HAAPI Web Sample:

- https://login.example.com/demo-client.html
- john.doe
- Password1

## Connect to the Identity Server Inside the Cluster

Start a shell and test connectivity to the Curity Identity Server:

- POD=$(kubectl get pods -o name | grep webhost)
- kubectl exec -it $POD -- sh
- curl -u 'admin:Password1' 'http://curity-idsvr-admin-svc:6749/admin/api/restconf/data?depth=unbounded&content=config'
- curl -k 'https://curity-idsvr-runtime-svc:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration'
