## Overview

A small repo for running an end to end solution on a MacBook with Istio and the Curity Identity Server

## Prerequisites

Install Docker for MacOS if required, then install Minikube as a local Kubernetes cluster:

- brew update
- brew install minikube
- minikube config set driver hyperkit

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

Istio requires different ingress components to a base Kubernetes install.\
This includes use of Gateway / Virtual Service / Destination Rule components:

- [Gateway](./base/https-gateway.yaml)
- [Virtual Services](./idsvr/virtualservices.yaml)
- [Destination Rules](./idsvr/destinationrules.yaml)

Extra networking objects then become available for managing the cluster:

- kubectl get gateway
- kubectl get virtualservice
- kubectl get destinationrule

## Use the System

The goal is to browse to these working URLs, though the second does not work currently:

- https://admin.example.com/admin
- https://login.example.com/oauth/v2/oauth-anonymous/.well-known/openid-configuration

Once working you will be able to do a login using the HAAPI Web Sample:

- https://login.example.com/demo-client.html
- john.doe
- Password1

## Make Calls between Internal Services

Start a shell and test connectivity to the Curity Identity Server:

- POD=$(kubectl get pods -o name | grep webhost)
- kubectl exec -it $POD -- sh
- curl -k -u 'admin:Password1' 'https://curity-idsvr-admin-svc:6749/admin/api/restconf/data?depth=unbounded&content=config'
- curl -k 'https://curity-idsvr-runtime-svc:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration'

Connectivity works though I should be able to avoid the -k parameter to bypass SSL Trust.\
For normal Kubernetes I have used [cert-manager](https://github.com/jetstack/cert-manager) to issue self signed internal certificates when pods start.

## Issue 1: Cluster Configuration

I experienced an error in the Cluster Conf Job due to the createConfigSecret openssl call failing.\
I think the cause was the openssl call being made too early, before the sidecar proxy was ready.\
It is resolved by overriding the default to avoid adding a sidecar to the job component:

- spec:
    template:
      metadata:
        annotations:
          sidecar.istio.io/inject: "false"

## Issue 2: Slow Startup

Curity PODS take 5 to 10 minutes to reach a ready state and are quite a bit slower than usual.\
I need to understand how to troubleshoot this better.

## Current State

- Deployment produces a working Admin UI
- Runtime Node connects to Admin Node after 5 to 10 minutes - but not always
- Runtime Node connection works externally but no OIDC metadata is returned
- Cannot call admin node inside the cluster - though it has worked before
- Cannot call runtime node inside the cluster - this has never worked

## Tasks

- Upgrade to a MySql connection and 2 runtime nodes
- Get the backup script working with data for john.doe test user
- Get HAAPI web sample working
- Use the [yq tool](https://github.com/mikefarah/yq) to automate the update to apply the annotation to the cluster job