#!/bin/bash

###########################################################################################
# Deploy a minimal pod in the applications namespace from which we can issue a curl request
###########################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
kubectl -n applications run curlclient --image=curlimages/curl -it -- sh

#
# Use these internal requests from inside the utility pod, to make mTLS requests routed via sidecars
#
# curl -u 'admin:Password1' 'http://curity-idsvr-admin-svc.curity:6749/admin/api/restconf/data?depth=unbounded&content=config'
# curl http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration
#

#
# Use these requests from outside the cluster, to verify that external URLs are working
#
# - curl -k -u 'admin:Password1' 'https://admin.curity.local/admin/api/restconf/data?depth=unbounded&content=config'
# - curl -k https://login.curity.local/oauth/v2/oauth-anonymous/.well-known/openid-configuration
#
