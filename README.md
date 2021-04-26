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

Then view ingress and egress gateways which are used instead of the default Kubernetes ingress:

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
- 10.108.72.131 login.example.com 
- 10.108.72.131 admin.example.com 

Also add the root certificate at `certs/example.com.ca.pem` to Keychain Access under System/Certificates.

## Deploy a Very Simple Component

To understand the basics of Kubernetes and Istio routing see this script:

- ./deploy-webhost.sh

 Then browse to the web URL to see some HTML:

- https://web.example.com

## Deploy the Curity Identity Server

Execute these commands to deploy a SQL database and the Identity Server to the cluster:

- ./deploy-mysql.sh
- ./deploy-idsvr.sh

## View Sidecar Components

Note how all pods, including those for the Curity Identity Server, now include a sidecar component called 'istio-proxy':

- kubectl get pods
- kubectl describe pod/dev-idsvr-runtime-84c859d6df-75wvp

This is because we made Istio injection the default behavior:

- kubectl label namespace default istio-injection=enabled

## View Ingress Details

The main thing that works differently is the ingress which now uses Istio specific components:

- [Admin Ingress](./idsvr/ingress-admin.yaml)
- [Runtime Ingress](./idsvr/ingress-runtime.yaml)

## Use the System

Browse to these working URLs:

- https://admin.example.com/admin
- https://login.example.com/oauth/v2/oauth-anonymous/.well-known/openid-configuration

Log in to the HAAPI Web Sample with these details:

- https://login.example.com/demo-client.html
- john.doe
- Password1

## Make Calls between PODs

Start a shell in a runtime node and call the admin node to get configuration:

- kubectl exec -it pod/dev-idsvr-runtime-84c859d6df-75wvp -- bash
- curl -k -u 'admin:Password1' 'https://dev-idsvr-admin-svc:6749/admin/api/restconf/data?depth=unbounded&content=config'

## Problem 1

The one issue I found is explained in the [Deploy Idsvr Script](./deploy-idsvr.sh).\
To fix it I had to reverse engineer the Helm chart and edit the [Cluster Conf Job](./idsvr/yaml/cluster-conf-job.yaml).\
The result is to override the default and avoid adding a sidecar to the job component:

- spec:
    template:
      metadata:
        annotations:
          sidecar.istio.io/inject: "false"

## Problem 2

For now I have added the same annotation to deployment-admin.yaml and deployment-runtime.yaml.\
This is meant to be temporary to rule out some categories of problem.