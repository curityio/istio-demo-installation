#!/bin/bash

####################################################################
# Base setup for a cluster with 2 nodes hosting the application pods
####################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create a KIND cluster
#
kind delete cluster --name=curity 2>/dev/null
kind create cluster --name=curity --config=./cluster/cluster.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the Kubernetes cluster'
  exit 1
fi

#
# Create a folder for temporary resources
#
if [ -d ./resources ]; then
  rm -rf resources
fi
mkdir resources
cd resources

#
# Download Istio
#
curl -L https://istio.io/downloadIstio | sh -
if [ $? -ne 0 ]; then
  echo 'Problem encountered downloading Istio'
  exit 1
fi

#
# Install Istio components
#
cd istio*
./bin/istioctl install --set profile=demo -y
if [ $? -ne 0 ]; then
  echo 'Problem encountered installing Istio'
  exit 1
fi
cd ../..

#
# This is specific to local computer setups and would not be run for a cloud deployment
# It enables the host computer to send requests for port 443 to the ingress controller's container
# This relies on port 443 being included in extraPortMappings in the cluster.yaml file
# https://kind.sigs.k8s.io/docs/user/ingress
#
kubectl patch service    -n istio-system istio-ingressgateway -p '{"spec":{"type":"NodePort"}}'
kubectl patch deployment -n istio-system istio-ingressgateway --patch-file ./cluster/istio-development-ports.json
if [ $? -ne 0 ]; then
  echo 'Problem encountered patching the Istio ingress controller'
  exit 1
fi

#
# Create the Curity namespace
#
kubectl apply -f cluster/namespace.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating namespaces'
  exit 1
fi
