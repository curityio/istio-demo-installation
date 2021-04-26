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
kubectl delete deploy/webhost       2>/dev/null
kubectl delete service/webhost-svc  2>/dev/null
kubectl apply -f webhost/kubernetes/service.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered deploying the service for the web host"
  exit 1
fi

#
# Expose via an Istio ingress
#
kubectl delete gateway/webhost-gateway      2>/dev/null
kubectl delete virtualservice/webhost-route 2>/dev/null
kubectl apply -f webhost/kubernetes/ingress.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered creating the ingress for the web host"
  exit 1
fi

#
# Once the pod comes up we can access it over the following URL:
# - curl https://web.example.com
#
