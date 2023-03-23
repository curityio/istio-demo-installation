#!/bin/bash

###################################################################################################
# Deploy the Istio utility sleep pod, from which we will call the Curity Identity Server using mTLS
###################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create a namespace for applications
#
kubectl delete -f ./namespace.yaml 2>/dev/null
kubectl apply -f ./namespace.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the applications namespace'
  exit 1
fi

#
# Deploy the Istio sleep pod, which will be used to make internal OAuth requests using curl commands
#
kubectl -n applications delete -f ../cluster/istio*/samples/sleep/sleep.yaml 2>/dev/null
kubectl -n applications apply  -f ../cluster/istio*/samples/sleep/sleep.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the sleep Docker image'
  exit 1
fi
