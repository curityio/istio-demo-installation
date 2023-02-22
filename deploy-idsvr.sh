#!/bin/bash

#######################################################################################
# Deploy the Curity Identity Server cluster to Kubernetes, with backed up configuration
#######################################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Check prerequisites
#
if [ ! -f './idsvr/license.json' ]; then
  echo 'Please provide a license.json file in the idsvr folder in order to deploy the system'
  exit 1
fi

#
# Initial setup
#
cp ./hooks/pre-commit ./.git/hooks

#
# Create the Curity namespace if required
#
kubectl apply -f cluster/namespace.yaml 2>/dev/null

#
# Build a custom docker image containing some extra resources
#
docker build -f idsvr/Dockerfile -t custom_idsvr:8.0.0 .
if [ $? -ne 0 ]; then
  echo 'Problem encountered building the Identity Server custom docker image'
  exit 1
fi

#
# Load it into the KIND docker registry
#
kind load docker-image custom_idsvr:8.0.0 --name curity
if [ $? -ne 0 ]; then
  echo 'Problem encountered loading the Identity Server custom docker image into the KIND registry'
  exit 1
fi

#
# Create the config map referenced in the helm-values.yaml file
# This deploys XML configuration to containers at /opt/idsvr/etc/init/configmap-config.xml
#
kubectl -n curity delete configmap idsvr-configbackup 2>/dev/null
kubectl -n curity create configmap idsvr-configbackup --from-file='configbackup=./idsvr/idsvr-config-backup.xml'
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the config map for the Identity Server'
  exit 1
fi

#
# Run the Curity Identity Server Helm Chart to deploy an admin node and two runtime nodes
#
helm repo add curity https://curityio.github.io/idsvr-helm
helm repo update
helm uninstall curity --namespace curity 2>/dev/null
helm install curity curity/idsvr --values=idsvr/helm-values.yaml --namespace curity
if [ $? -ne 0 ]; then
  echo 'Problem encountered running the Helm Chart for the Curity Identity Server'
  exit 1
fi

#
# Create a Kubernetes secret for the external SSL certificate, to apply to the Istio ingress
# Note that the secret must be created within the istio-system namespace
#
kubectl -n istio-system delete secret curity-external-tls 2>/dev/null
kubectl -n istio-system create secret tls curity-external-tls --cert=./certs/curity.local.ssl.pem --key=./certs/curity.local.ssl.key
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the Kubernetes TLS secret for the Curity Identity Server'
  exit 1
fi

#
# Expose endpoints using Istio's ingress
#
kubectl -n curity delete -f ./idsvr/ingress.yaml 2>/dev/null
kubectl -n curity apply  -f ./idsvr/ingress.yaml
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the ingress for the Curity Identity Server'
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
# curl -k -u 'admin:Password1' 'https://curity-idsvr-admin-svc:6749/admin/api/restconf/data?depth=unbounded&content=config'
# curl -k https://curity-idsvr-runtime-svc:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration
#
