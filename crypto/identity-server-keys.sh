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
# Create a token signing keypair
#
openssl genrsa -out signing.key 2048
openssl req -new -nodes -key signing.key -out signing.csr -subj "/CN=example.signing"
openssl x509 -req -in signing.csr -signkey signing.key -out signing.crt -sha256 -days 365
openssl pkcs12 -export -inkey signing.key -in signing.crt -name curity.signing -out signing.p12 -passout pass:Password1

#
# Create a symmetric key for encrypting identity server cookies
#
openssl rand 32 | xxd -p -c 64 > symmetric.key

#
# Create a config encryption key for protecting secure environment variables
#
openssl rand 32 | xxd -p -c 64 > configencryption.key

#
# Clean up
#
rm signing.key
rm signing.crt
rm signing.csr