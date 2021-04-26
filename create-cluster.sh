#!/bin/bash

######################################################################
# A script to use Istio with a Minikube cluster on a Developer MacBook
######################################################################

#
# Create or start the cluster
# https://istio.io/latest/docs/setup/platform-setup/minikube
#
minikube start --cpus=4 --memory=16384 --disk-size=100g --kubernetes-version=v1.21.0 --profile example

#
# Download Istio to the Macbook
# https://istio.io/latest/docs/setup/getting-started
#
cd ~
curl -L https://istio.io/downloadIstio | sh -

#
# Install Istio to the cluster, referencing the file at ~/istio-1.9.3/manifests/profiles/demo.yaml
#
~/istio-1.9.3/bin/istioctl install --set profile=demo -y

#
# Automatically add an 'istio-proxy' sidecar component to all Kubernetes services
#
kubectl label namespace default istio-injection=enabled

#
# Finally create a secret for the wildcard external SSL certificate for *.example.com
#
cd -
kubectl delete -n istio-system secret example-com-tls 2>/dev/null
kubectl create -n istio-system secret tls example-com-tls --cert='./certs/example.com.ssl.pem' --key='./certs/example.com.ssl.key'
if [ $? -ne 0 ]
then
  echo "*** Problem creating secret for external SSL certificate ***"
  exit 1
fi

#
# When finished with the cluster you can stop or delete it like this
# minikube stop --profile example
# minikube delete --profile example
#
