#!/bin/bash

##################################################################################################
# Deploy the httpbin demo application and get mTLS working for calls to the Curity Identity Server
##################################################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Build a custom docker image containing some extra resources
#
docker build -f httpbin/Dockerfile -t custom_httpbin:1.0.0 .
if [ $? -ne 0 ]; then
  echo 'Problem encountered building the httpbin custom docker image'
  exit 1
fi

#
# Load it into the KIND docker registry
#
kind load docker-image custom_httpbin:1.0.0 --name curity
if [ $? -ne 0 ]; then
  echo 'Problem encountered loading the httpbin custom docker image into the KIND registry'
  exit 1
fi

#
# Deploy the httpbin pod, which is configured to use a sidecar and mTLS
#
kubectl -n applications delete -f ./httpbin/httpbin.yaml 2>/dev/null
kubectl -n applications apply  -f ./httpbin/httpbin.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating application resources'
  exit 1
fi

#
# Once pods come up we can call them over these HTTPS URLs externally:
#
# - curl -k -u 'admin:Password1' 'https://admin.curity.local/admin/api/restconf/data?depth=unbounded&content=config'
# - curl -k https://login.curity.local/oauth/v2/oauth-anonymous/.well-known/openid-configuration
#
# Inside the cluster we can use these HTTP URLs:
#
# curl -u 'admin:Password1' 'http://curity-idsvr-admin-svc.curity:6749/admin/api/restconf/data?depth=unbounded&content=config'
# curl http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration
#
