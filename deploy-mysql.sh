#!/bin/bash

#####################################################################################
# Deploy a basic MySql instance without any persistent volumes
# The Curity Identity Server will connect to it via this JDBC URL inside the cluster:
# - jdbc:mysql://mysql-svc/idsvr?serverTimezone=Europe/Stockholm
#####################################################################################

#
# Point to our minikube profile
#
minikube profile example
eval $(minikube docker-env --profile example)
if [ $? -ne 0 ];
then
  echo "Minikube problem encountered - please ensure that the service is started"
  exit 1
fi

#
# Tear down the instance and lose all data, which will be reapplied from the backup
#
kubectl delete -f mysql/service.yaml 2>/dev/null

#
# Build a custom docker image containing backed up data
#
docker build -f mysql/Dockerfile -t custom_mysql:8.0.22 .
if [ $? -ne 0 ];
then
  echo "Problem encountered building the custom MySql docker image"
  exit 1
fi

#
# Deploy the mysql instance
#
kubectl apply -f mysql/service.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered deploying the MySql service"
  exit 1
fi

#
# Once the pod comes up we can connect to it as follows from the MacBook, if MySql is installed:
# - mysql -h $(minikube ip) -P 30306 -D idsvr -u root -pPassword1
#
# From Curity containers inside the cluster we can use the following command:
# - mysql -h mysql-svc -P 3306 -D idsvr -u root -pPassword1
#