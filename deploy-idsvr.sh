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
# Get the latest helm chart
#
helm repo add curity https://curityio.github.io/idsvr-helm 2>/dev/null
helm repo update

#
# Uninstall the existing version if applicable
#
# helm uninstall curity 2>/dev/null

#
# Create the config map referenced in the idsvr-values file, whose data can then be viewed with the below command:
# - kubectl get configmap idsvr-configmap -o yaml
#
# kubectl delete configmap idsvr-configmap 2>/dev/null
# kubectl create configmap idsvr-configmap --from-file='./idsvr/config-backup.xml'
if [ $? -ne 0 ];
then
  echo "Problem encountered creating the config map for the Identity Server"
  exit 1
fi

#
# The simple option is to use Helm directly like this:
# - helm install dev curity/idsvr --values=idsvr/idsvr-values.yaml
#
# However, this leads to the following error in cluster-conf-job.yaml
# - 139906036158912:error:0200206F:system library:connect:Connection refused:../crypto/bio/b_sock2.c:110:
# - 139906036158912:error:2008A067:BIO routines:BIO_connect:connect error:../crypto/bio/b_sock2.c:111:
# - connect:errno=111
#
# I think the cause is that the sidecar is not fully running when the script in cluster-conf-configmap.yaml runs
# This means openssl cannot connect to the cluster
#
# I then extracted individual YAML files from the below command:
# - helm install dev curity/idsvr --values=idsvr/idsvr-values.yaml --dry-run --debug
#
# I also patched the cluster-conf-job.yaml script with an annotation to delay execution until the sidecar is ready:
# https://github.com/istio/istio/issues/11130
#
# The solution I found was to disable Istio sidecars for the configuration job:
# https://stackoverflow.com/questions/59235887/how-to-disable-istio-on-k8s-job
# - sidecar.istio.io/inject: "false"
#
# Other options exist such as waiting for the sidecar to be fully running before running the job, though this did not work:
# - proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'
#
#
kubectl apply -f idsvr/yaml/network-policy.yaml
kubectl apply -f idsvr/yaml/service-account.yaml
kubectl delete -f idsvr/yaml/cluster-conf-secret.yaml
kubectl apply -f idsvr/yaml/cluster-conf-secret.yaml
kubectl delete -f idsvr/yaml/cluster-conf-configmap.yaml
kubectl apply -f idsvr/yaml/cluster-conf-configmap.yaml
kubectl apply -f idsvr/yaml/role.yaml
kubectl apply -f idsvr/yaml/role-binding.yaml
kubectl apply -f idsvr/yaml/service-admin.yaml
kubectl apply -f idsvr/yaml/service-runtime.yaml
kubectl apply -f idsvr/yaml/deployment-admin.yaml
kubectl apply -f idsvr/yaml/deployment-runtime.yaml
kubectl delete -f idsvr/yaml/cluster-conf-job.yaml
kubectl apply -f idsvr/yaml/cluster-conf-job.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered starting the Helm Chart installation for the Identity Server"
  exit 1
fi

#
# Expose the admin UI via an Istio ingress
#
kubectl delete gateway/idsvr-admin-gateway                 2>/dev/null
kubectl delete destinationrule/idsvr-admin-destinationrule 2>/dev/null   
kubectl delete virtualservice/idsvr-admin-virtualservice   2>/dev/null
kubectl apply -f idsvr/ingress-admin.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered creating the ingress for the identity server admin node"
  exit 1
fi

#
# Expose the runtime via an Istio ingress
#
kubectl delete gateway/idsvr-runtime-gateway                 2>/dev/null
kubectl delete destinationrule/idsvr-runtime-destinationrule 2>/dev/null   
kubectl delete virtualservice/idsvr-runtime-virtualservice   2>/dev/null
kubectl apply -f idsvr/ingress-runtime.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered creating the ingress for the identity server runtime nodes"
  exit 1
fi

#
# Once the pods come up we can call them over these URLs:
#
# curl https://admin.example.com/admin/login/login.html
# curl https://login.example.com/oauth/v2/oauth-anonymous/.well-known/openid-configuration
