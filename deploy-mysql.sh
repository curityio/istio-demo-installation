#!/bin/bash

############################################################################################
# Deploy a basic MySql server instance and manage backups and restores via scripts
#
# I can then connect to it from my MacBook host via this command:
# - mysql -h $(minikube ip) -P 30306 -D idsvr -u root -pPassword1
#
# From the pod use this command instead:
# - mysql -h 127.0.0.1 -P 3306 -D idsvr -u root -pPassword1
#
# The Curity Identity Server will connect to the database using the Kubernetes service name:
# - jdbc:mysql://mysql-svc/idsvr
############################################################################################

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
