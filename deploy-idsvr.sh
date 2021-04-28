#!/bin/bash

#########################################################################################################
# Deploy the Curity Identity Server cluster to Kubernetes, with backed up configuration and Istio routing
#########################################################################################################

#
# Point to the minikube profile
#
minikube profile example
eval $(minikube docker-env --profile example)
if [ $? -ne 0 ];
then
  echo "Minikube problem encountered - please ensure that the service is started"
  exit 1
fi

#
# Build a custom docker image with a mysql driver and some development tools
#
docker build -f idsvr/Dockerfile -t custom_idsvr:6.1.0 .
if [ $? -ne 0 ];
then
  echo "Problem encountered building the Identity Server custom docker image"
  exit 1
fi

#
# Uninstall the existing system if applicable
#
kubectl delete -f idsvr/idsvr.yaml 2>/dev/null

#
# Create the config map referenced in the helm-values.yaml file
# This deploys XML configuration to containers at /opt/idsvr/etc/init/configmap-config.xml
# - kubectl get configmap idsvr-configmap -o yaml
#
kubectl delete configmap idsvr-configmap 2>/dev/null
kubectl create configmap idsvr-configmap --from-file='./idsvr/idsvr-config-backup.xml'
if [ $? -ne 0 ];
then
  echo "Problem encountered creating the config map for the Identity Server"
  exit 1
fi

#
# Get the raw Kubernetes yaml from the Helm chart for finer control over behavior
# Running the Helm chart directly leads to the following openssl connection error in cluster-conf-job.yaml
# - 139906036158912:error:0200206F:system library:connect:Connection refused:../crypto/bio/b_sock2.c:110:
# - 139906036158912:error:2008A067:BIO routines:BIO_connect:connect error:../crypto/bio/b_sock2.c:111:
# - connect:errno=111
#
HELM_FOLDER=~/tmp/idsvr-helm
rm -rf $HELM_FOLDER
git clone https://github.com/curityio/idsvr-helm $HELM_FOLDER
cp idsvr/helm-values.yaml $HELM_FOLDER/idsvr
#helm template curity $HELM_FOLDER/idsvr --values $HELM_FOLDER/idsvr/helm-values.yaml > idsvr/idsvr-complete.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered creating Kubernetes YAML from the Identity Server Helm Chart"
  exit 1
fi

#
# I looked at a couple of solutions:
# https://github.com/istio/istio/issues/11130
# https://stackoverflow.com/questions/59235887/how-to-disable-istio-on-k8s-job
#
# The one I chose was to set this annotation for the cluster-conf-job to avoid use of a sidecar:
# I would like to automate this, perhaps using the yq tool
#
# spec:
#   template:
#      metadata:
#        annotations:
#          sidecar.istio.io/inject: "false"
#

#
# Force a redeploy of the system
#
kubectl delete -f idsvr/idsvr-complete.yaml 2>/dev/null
kubectl apply -f idsvr/idsvr-complete.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered applying Kubernetes YAML"
  exit 1
fi

#
# Expose HTTPS endpoints via an Istio gateway and virtual service
#
kubectl delete -f idsvr/virtualservices.yaml 2>/dev/null
kubectl apply -f  idsvr/virtualservices.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered creating Istio virtual services to expose HTTP endpoints"
  exit 1
fi

#
# Add destination rules so that Identity Server nodes can be reached via TLS inside the cluster
#
kubectl delete -f idsvr/destinationrules.yaml 2>/dev/null
kubectl apply  -f idsvr/destinationrules.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered creating Istio destination rules to allow TLS inside the cluster"
  exit 1
fi

#
# Once the pods come up we can call them over these URLs externally:
#
# - curl -u 'admin:Password1' 'https://admin.example.com/admin/api/restconf/data?depth=unbounded&content=config'
# - curl 'https://login.example.com/oauth/v2/oauth-anonymous/.well-known/openid-configuration'
#
# Inside the cluster we can use these URLs: 
#
# curl -k -u 'admin:Password1' 'https://curity-idsvr-admin-svc:6749/admin/api/restconf/data?depth=unbounded&content=config'
# curl -k 'https://curity-idsvr-runtime-svc:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration'
#
