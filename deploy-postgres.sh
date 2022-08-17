#!/bin/bash

#####################################################################################
# Deploy a basic Postgres instance without any persistent volumes
# The Curity Identity Server will connect to it via this JDBC URL inside the cluster:
# - jdbc:postgresql://postgres-svc/idsvr
# From Curity containers inside the cluster we can connect via the following command:
# - export PGPASSWORD=Password1 && psql -p 5432 -d idsvr -U postgres
#####################################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Copy in the init script to restore data, which includes our test user account
#
kubectl -n curity delete configmap init-script-configmap 2>/dev/null
kubectl -n curity create configmap init-script-configmap --from-file='./postgres/idsvr-data-backup.sql'

#
# Deploy a postgres instance
#
kubectl -n curity delete -f postgres/service.yaml 2>/dev/null
kubectl -n curity apply -f postgres/service.yaml
if [ $? -ne 0 ]; then
  echo "Problem encountered deploying the PostgreSQL service"
  exit 1
fi
