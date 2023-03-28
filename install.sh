#!/bin/bash

######################################################################################################
# An install script to deploy a cluster that uses an Istio service mesh and the Curity Identity Server
######################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Do the base cluster setup - replace this logic to deploy to your cloud platform
#
./cluster/install.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the Curity Identity Server to run in a sidecar based setup
#
./idsvr/install.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Also deploy utility pod that can make HTTP requests to the Curity Identity Server
#
./utility/install.sh
if [ $? -ne 0 ]; then
  exit 1
fi