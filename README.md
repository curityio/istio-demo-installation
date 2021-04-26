## Overview

A small repo for running an end to end solution on a MacBook with Istio and the Curity Identity Server

## Prerequisites

Install Docker for MacOS if required, then install Minikube as a local Kubernetes cluster:

- brew update
- brew install minikube
- minikube config set driver hyperkit

## Cluster Base Setup

Run this script:

- ./create-cluster.sh

Then view ingress and egress gateways which are used instead of the default Kubernetes ingress:

- kubectl get all -n istio-system
- kubectl -n istio-system describe service istio-ingressgateway

Then add ~/istio-1.9.3/bin to your PATH environment variable in ~/.zprofile and restart the terminal.

## URL Setup

Run `minikube tunnel --profile example` to provide an external IP address.\
Then run `kubectl get svc istio-ingressgateway -n istio-system` to identify it.\
Then run `sudo vi /etc/hosts`and add entries similar to this using the external IP address:

- 10.108.72.131 web.example.com
- 10.108.72.131 login.example.com 
- 10.108.72.131 admin.example.com 

Also add the root certificate at `certs/example.com.ca.pem` to Keychain Access / System / Certificates

## Deploy a Simple Web Host

To understand the basics of Kubernetes and Istio routing run this script:

- ./deploy-webhost.sh

 Then browse to the web URL to see some HTML:

- https://web.example.com

## Deploy the Curity Identity Server

In a terminal, move to the curity-deployment folder and execute these commands:

- ./deploy-mysql.sh
- ./deploy-idsvr.sh

Then browse to these URLs:

- https://admin.example.com/admin
- https://login.example.com/oauth/v2/oauth-anonymous/.well-known/openid-configuration

## View Sidecar Components

Note how all pods, including those for the Curity Identity Server, now include a sidecar component called 'istio-proxy':

- kubectl describe pod/curity-idsvr-runtime-66df984bf8-jbjmz

## TODO:

- Configuration pod has a problem:
  kubectl get events --sort-by='.lastTimestamp'
  'kubectl describe pod' previously showed the cluster-conf-job is completed but it shows as NotReady in 'kubectl get all'

- MySql from outside
  Does NodePort work with Istio?

