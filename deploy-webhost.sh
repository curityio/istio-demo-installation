#!/bin/bash

#
# Point Minikube and Docker to our profile
#
minikube profile example
eval $(minikube docker-env --profile example)
if [ $? -ne 0 ];
then
  echo "Minikube problem encountered - please ensure that the service is started"
  exit 1
fi

#
# Build the docker image for the web host
#
docker build --no-cache -f webhost/kubernetes/Dockerfile -t webhost:v1 .
if [ $? -ne 0 ];
then
  echo "Docker build problem encountered"
  exit 1
fi

#
# Deploy the docker image
#
kubectl delete -f webhost/kubernetes/service.yaml 2>/dev/null
kubectl apply  -f webhost/kubernetes/service.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered deploying the service for the web host"
  exit 1
fi

#
# Expose via an Istio ingress
#
kubectl delete -f webhost/kubernetes/virtualservice.yaml 2>/dev/null
kubectl apply  -f webhost/kubernetes/virtualservice.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered creating the ingress for the web host"
  exit 1
fi

#
# Once the pod comes up we can access it over the following external and internal URLs:
# - curl https://web.example.com
# - curl http://webhost-svc:3000
#
