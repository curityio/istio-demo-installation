#!/bin/bash

####################################################################
# Base setup for a cluster with 2 nodes hosting the application pods
####################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create a KIND cluster
#
kind delete cluster --name=istio-demo 2>/dev/null
kind create cluster --name=istio-demo --config=./cluster.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the Kubernetes cluster'
  exit 1
fi

#
# Download Istio
#
rm -rf istio-* 2>/dev/null
curl -L https://istio.io/downloadIstio | sh -
if [ $? -ne 0 ]; then
  echo 'Problem encountered downloading Istio'
  exit 1
fi

#
# Install Istio components and activate a development option to enable eavesdropping of mTLS requests
#
./istio-*/bin/istioctl install --set profile=demo -y
if [ $? -ne 0 ]; then
  echo 'Problem encountered installing Istio'
  exit 1
fi

#
# In local development setups, this sends port 443 requests to the ingress controller's container
# This relies on port 443 being included in extraPortMappings in the cluster.yaml file
# https://kind.sigs.k8s.io/docs/user/ingress
#
kubectl patch service    -n istio-system istio-ingressgateway -p '{"spec":{"type":"NodePort"}}'
kubectl patch deployment -n istio-system istio-ingressgateway --patch-file ./ingress-development-ports.json
if [ $? -ne 0 ]; then
  echo 'Problem encountered patching the Istio ingress controller'
  exit 1
fi

#
# Create external SSL certificates, used by the Istio ingress on a development computer
#
./ingress-certificates/create.sh
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating certificates for the Istio ingress'
  exit 1
fi

#
# Create a Kubernetes secret for the external SSL certificate, to apply to the Istio ingress
# Note that the secret must be created within the istio-system namespace
#
kubectl -n istio-system delete secret curity-external-tls 2>/dev/null
kubectl -n istio-system create secret tls curity-external-tls \
  --cert=./ingress-certificates/curity.external.ssl.pem \
  --key=./ingress-certificates/curity.external.ssl.key
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the Kubernetes TLS secret for the Curity Identity Server'
  exit 1
fi
