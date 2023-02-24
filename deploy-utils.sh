#!/bin/bash

###########################################################
# Deploy utility pods for testing and diagnosing mutual TLS
###########################################################

#
# First deploy sleep, as a curl client
#
kubectl -n applications delete -f utils/client.yaml 2>/dev/null
kubectl -n applications apply  -f utils/client.yaml

#
# Next deploy httpbin, as a utility that can echo back headers to provide evidence when mTLS is being used
#
kubectl -n applications delete -f utils/service.yaml 2>/dev/null
kubectl -n applications apply  -f utils/service.yaml

#
# Use these internal requests from inside the client pod, to call the Curity Identity Server
#
# curl -u 'admin:Password1' 'http://curity-idsvr-admin-svc.curity:6749/admin/api/restconf/data?depth=unbounded&content=config'
# curl http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration
#

#
# Use these requests from outside the cluster, to verify that Curity Identity Server external URLs are working
#
# - curl -k -u 'admin:Password1' 'https://admin.curity.local/admin/api/restconf/data?depth=unbounded&content=config'
# - curl -k https://login.curity.local/oauth/v2/oauth-anonymous/.well-known/openid-configuration
#
