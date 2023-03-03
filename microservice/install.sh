#!/bin/bash

#############################################################################################
# Deploy a utility microservice that could call the Curity Identity Server inside the cluster
#############################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Use the httpbin Istio sample as a custom API
#
docker build -t custom_httpbin:latest .
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating a custom httpbin Docker image'
  exit 1
fi

#
# Load it into the KIND docker registry
#
kind load docker-image custom_httpbin:latest --name curity
if [ $? -ne 0 ]; then
  echo 'Problem encountered loading the httpbin custom docker image into the KIND registry'
  exit 1
fi

#
# Deploy the Istio httpbin example
#
kubectl -n applications delete -f httpbin.yaml 2>/dev/null
kubectl -n applications apply  -f httpbin.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating a custom httpbin Docker image'
  exit 1
fi
