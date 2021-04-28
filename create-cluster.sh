#!/bin/bash

######################################################################
# A script to use Istio with a Minikube cluster on a Developer MacBook
######################################################################

#
# Create or start the cluster
# https://istio.io/latest/docs/setup/platform-setup/minikube
#
minikube delete --profile example
minikube start --cpus=4 --memory=16384 --disk-size=100g --kubernetes-version=v1.21.0 --profile example

#
# Download Istio to the Macbook
# https://istio.io/latest/docs/setup/getting-started
#
cd ~
curl -L https://istio.io/downloadIstio | sh -

#
# Install Istio to the cluster, referencing the file at ~/istio-1.9.3/manifests/profiles/demo.yaml
# The demo profile has good defaults when getting started, though other options are also available:
# - https://istio.io/latest/docs/setup/additional-setup/config-profiles
#
~/istio-1.9.3/bin/istioctl install --set profile=demo -y

#
# Automatically add an 'istio-proxy' sidecar component to all Kubernetes services
#
kubectl label namespace default istio-injection=enabled

#
# Create a secret for the wildcard external SSL certificate for *.example.com
# Note that this must be deployed to the istio-system namespace
#
cd -
kubectl delete secret example-com-tls -n istio-system 2>/dev/null
kubectl create secret tls example-com-tls --cert='./certs/example.com.ssl.pem' --key='./certs/example.com.ssl.key' -n istio-system
if [ $? -ne 0 ]
then
  echo "*** Problem creating secret for external SSL certificate ***"
  exit 1
fi

#
# Create the gateway object to expose services over port 443
#
kubectl delete -f base/gateway.yaml 2> /dev/null
kubectl apply  -f base/gateway.yaml