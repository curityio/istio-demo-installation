#!/bin/bash

#######################################################################################
# Deploy the Curity Identity Server cluster to Kubernetes, with backed up configuration
#######################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
cd ..

#
# Prevent potential checkins of secrets
#
cp ./hooks/pre-commit ./.git/hooks

#
# Get the license key
#
if [ "$CURITY_LICENSE_FILE_PATH" == '' ]; then
  echo '*** Please provide a CURITY_LICENSE_FILE_PATH environment variable, pointing to a license file for the Curity Identity Server'
  exit 1
fi

export LICENSE_KEY=$(cat $CURITY_LICENSE_FILE_PATH | jq -r .License)
if [ "$LICENSE_KEY" == '' ]; then
  echo '*** An invalid license file was provided for the Curity Identity Server'
  exit 1
fi

#
# Build a custom docker image containing some extra resources
#
docker build -f idsvr/Dockerfile -t custom_idsvr:8.0.0 .
if [ $? -ne 0 ]; then
  echo 'Problem encountered building the Identity Server custom docker image'
  exit 1
fi
cd idsvr

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
kubectl -n curity create configmap idsvr-configbackup --from-file='configbackup=./idsvr-config-backup.xml'
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the config map for the Identity Server'
  exit 1
fi

#
# Dot source the script to create secure environment variables, so that they are exported
# Note that the Helm chart creates additional SSL_KEY and SIGNING_KEY environment variables
#
. ./crypto/create-environment-variables.sh
if [ $? -ne 0 ]; then
  exit 1
fi
cd ..

#
# Run envsubst to provide the final Helm chart
#
envsubst < ./helm-values-template.yaml > ./helm-values.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the cluster.yaml file'
  exit 1
fi

#
# Run the Curity Identity Server Helm Chart to deploy an admin node and two runtime nodes
#
helm repo add curity https://curityio.github.io/idsvr-helm
helm repo update
helm uninstall curity --namespace curity 2>/dev/null
helm install curity curity/idsvr --values=helm-values.yaml --namespace curity
if [ $? -ne 0 ]; then
  echo 'Problem encountered running the Helm Chart for the Curity Identity Server'
  exit 1
fi

#
# Create a Kubernetes secret for the external SSL certificate, to apply to the Istio ingress
# Note that the secret must be created within the istio-system namespace
#
kubectl -n istio-system delete secret curity-external-tls 2>/dev/null
kubectl -n istio-system create secret tls curity-external-tls --cert=../crypto/curity.external.ssl.pem --key=../crypto/curity.external.ssl.key
if [ $? -ne 0 ]; then
  echo 'Problem encountered creating the Kubernetes TLS secret for the Curity Identity Server'
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