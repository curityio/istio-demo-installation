#!/bin/bash

####################################################################
# A script to back up the Curity configuration and also its SQL data
# For development purposes the data is then saved to the GitHub repo
####################################################################

#
# Remote to the pod and do the SQL backup there
#
DATA_FILE_NAME=idsvr-data-backup.sql
MYSQL_POD=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep mysql)
kubectl exec -it "pods/$MYSQL_POD" -- bash -c "mysqldump -u root -pPassword1 idsvr > /tmp/$DATA_FILE_NAME"
if [ $? -ne 0 ]
then
  echo "MySql backup problem encountered"
  exit 1
fi

#
# Then copy the SQL data locally, where it can be checked into the GitHub repo
#
kubectl cp default/$MYSQL_POD:tmp/$DATA_FILE_NAME ./mysql/$DATA_FILE_NAME
kubectl exec -it "pods/$MYSQL_POD" -- bash -c "rm /tmp/$DATA_FILE_NAME"
if [ $? -ne 0 ]
then
  echo "MySql file copy problem encountered"
  exit 1
fi

#
# Back up Curity configuration via the REST API
#
CONFIG_FILE_NAME=idsvr-config-backup.xml
curl -u 'admin:Password1' 'https://admin.example.com/admin/api/restconf/data?depth=unbounded&content=config' > ~/tmp/$CONFIG_FILE_NAME
if [ $? -ne 0 ]
then
  echo "Problem encountered backing up Identity Server configuration"
  exit 1
fi

#
# The Curity Identity Server cannot start when given backed up configuration in the RESTCONF format
# Currently I am doing a hacky conversion to the Admin UI download format
#
data=$(cat ~/tmp/$CONFIG_FILE_NAME)
restApiOpeningTag='<data xmlns="urn:ietf:params:xml:ns:yang:ietf-restconf">'
restApiClosingTag='<\/data>'
adminUIOpeningTag='<config xmlns="http:\/\/tail-f.com\/ns\/config\/1.0">'
adminUIClosingTag='<\/config>'
data=$(sed "s/$restApiOpeningTag/$adminUIOpeningTag/g" <<< "$data")
data=$(sed "s/$restApiClosingTag/$adminUIClosingTag/g" <<< "$data")
echo "$data" > ./idsvr/$CONFIG_FILE_NAME
rm ~/tmp/$CONFIG_FILE_NAME
