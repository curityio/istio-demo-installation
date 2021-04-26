#!/bin/bash

#####################################################################################
# Deploy a basic MySql server instance and manage backups and restores via scripts
# The Curity Identity Server will connect to it via this JDBC URL inside the cluster:
# - jdbc:mysql://mysql-svc/idsvr?serverTimezone=Europe/Stockholm
#####################################################################################

# Point to our minikube profile
minikube profile example
eval $(minikube docker-env --profile example)
if [ $? -ne 0 ];
then
  echo "Minikube problem encountered - please ensure that the service is started"
  exit 1
fi

# Tear down the instance and lose all data, since I am currently managing data via backup and restore scripts
kubectl delete deploy/mysql      2>/dev/null
kubectl delete service/mysql-svc 2>/dev/null

# Build a custom docker image with a SQL script to create the schema
docker build -f mysql/Dockerfile -t custom_mysql:8.0.22 .
if [ $? -ne 0 ];
then
  echo "Problem encountered building the custom MySql docker image"
  exit 1
fi

# Deploy the mysql instance, which for simplicity does not use persistent storage
kubectl apply -f mysql/service-mysql.yaml
if [ $? -ne 0 ];
then
  echo "Problem encountered deploying the MySql service"
  exit 1
fi

#
# Once the pod comes up we can connect to it as follows from the MacBook:
# - mysql -h $(minikube ip) -P 30306 -D idsvr -u root -pPassword1
#
# From another container we can instead use the following command:
# - mysql -h mysql-svc -P 3306 -D idsvr -u root -pPassword1
#