#!/bin/bash

##############################################################
# Deploy the Curity Identity Server to run with Istio sidecars
##############################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Run the Curity Identity Server Helm Chart to deploy an admin node and two runtime nodes
#
kubectl delete namespace curity 2>/dev/null
helm repo add curity https://curityio.github.io/idsvr-helm
helm repo update
helm install curity curity/idsvr --values=helm-values.yaml --namespace curity --create-namespace
if [ $? -ne 0 ]; then
  echo 'Problem encountered running the Helm Chart for the Curity Identity Server'
  exit 1
fi

#
# Deploy Istio specific custom resources for ingress and mTLS
#
kubectl -n curity delete -f ./istio-custom-resources.yaml 2>/dev/null
kubectl -n curity apply  -f ./istio-custom-resources.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating Istio resources for the Curity Identity Server'
  exit 1
fi
