#!/bin/bash

##########################################################################
# A script to create external development certificates for the demo system
# Istio issued certificates are instead used for internal URLs
##########################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create external certificates for the Istio ingress
#
./crypto/external-certs.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create keys for the Curity Identity Server
#
./crypto/identity-server-keys.sh
if [ $? -ne 0 ]; then
  exit 1
fi
