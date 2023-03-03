#!/bin/bash

#########################################################################################
# An install script to deploy a KIND and Istio cluster hosting the Curity Identity Server
#########################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Do the base cluster setup
#
./cluster/install.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the database for the Curity Identity Server
#
./postgres/install.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Run the deployment of the Curity Identity Server
#
#./idsvr/install.sh
if [ $? -ne 0 ]; then
  exit 1
fi