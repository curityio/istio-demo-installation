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

#
# Create the Curity namespace
#
cd ../..
kubectl apply -f cluster/namespace.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating namespaces'
  exit 1
fi