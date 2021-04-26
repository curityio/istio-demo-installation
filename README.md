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

## Issue 1 - Cluster Configuration

I experienced an error in the [Deploy Idsvr Script](./deploy-idsvr.sh).\
To fix it I had to reverse engineer the Helm chart and edit the [Cluster Conf Job](./idsvr/yaml/cluster-conf-job.yaml).\
It is resolved by overriding the default to avoid adding a sidecar to the job component:

- spec:
    template:
      metadata:
        annotations:
          sidecar.istio.io/inject: "false"

## Problem 2 - Slow Sidecar Startup

Pod startup times are very slow due to Istio sidecar taking 5 minutes to start.\
However, there is now slowness for my minimal web component, which quickly reaches Ready (2/2).\
I need to better understand this and google some more:

- https://github.com/istio/istio/issues/7817

Currently I am setting initialDelaySeconds=300 for the admin node and 600 for runtime nodes.\
Workaround is to use the inject=false annotation but this is not satisfactory.

## Problem 3 - SSL Trust Connecting to the Admin Node

Runtime node cannot connect to the admin node, with the following logs:

-  Setting cluster mode to Runtime, attempting to connect to master: dev-idsvr-admin-svc port 6789
- Runtime not connected to admin. Connection to admin closed

Eventually, after 5 minutes, both admin and runtime nodes go to Ready (2/2) state.\
When I run a curl command manually from the minimal web container I get this issue:

- curl: (35) error:1408F10B:SSL routines:ssl3_get_record:wrong version number

Workaround is to use the inject=false annotation on the admin node but this is not satisfactory.

One option might be to use cert-manager issued certificates inside the cluster.\
I need to google and perhaps troubleshoot this further with the openssl tool:

- https://github.com/istio/istio/issues/16531

## Problem 4 - Blocked SQL Connections

SQL connections may fail in a similar way:

- mysql -h mysql-svc -P 3306 -D idsvr -u root@mysql-svc -pPassword1

## TODO

- Resolve open issues and do more reading
- Get HAAPI web sample working
- Provide a brief write up of ingress / egress behavior
