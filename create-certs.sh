#!/bin/bash

##########################################################################
# A script to create external development certificates for the demo system
# Istio issued certificates are instead used for internal URLs
##########################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"
cd certs

#
# Point to the OpenSSL configuration file
#
case "$(uname -s)" in

  Darwin)
    export OPENSSL_CONF='/System/Library/OpenSSL/openssl.cnf'
 	;;

  Linux)
    export OPENSSL_CONF='/usr/lib/ssl/openssl.cnf';
 	;;

  MINGW64*)
    export OPENSSL_CONF='C:/Program Files/Git/usr/ssl/openssl.cnf';
    export MSYS_NO_PATHCONV=1;
	;;
esac

#
# External certificate details, for accesing the Curity Identity Server from outside the cluster
#
ROOT_CERT_FILE_PREFIX='curity.local.ca'
ROOT_CERT_DESCRIPTION='Self Signed CA for curity.local'
SSL_CERT_FILE_PREFIX='curity.local.ssl'
SSL_CERT_PASSWORD='Password1'
WILDCARD_DOMAIN_NAME='*.curity.local'

#
# Create the root certificate private key
#
openssl genrsa -out $ROOT_CERT_FILE_PREFIX.key 2048
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Get the root certificate public key
#
openssl req -x509 \
            -new \
            -nodes \
            -key $ROOT_CERT_FILE_PREFIX.key \
            -out $ROOT_CERT_FILE_PREFIX.pem \
            -subj "/CN=$ROOT_CERT_DESCRIPTION" \
            -reqexts v3_req \
            -extensions v3_ca \
            -sha256 \
            -days 365
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create the SSL key
#
openssl genrsa -out $SSL_CERT_FILE_PREFIX.key 2048

#
# Create the certificate signing request file
#
openssl req \
            -new \
			-key $SSL_CERT_FILE_PREFIX.key \
			-out $SSL_CERT_FILE_PREFIX.csr \
			-subj "/CN=$WILDCARD_DOMAIN_NAME"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create the SSL certificate and private key
#
openssl x509 -req \
			-in $SSL_CERT_FILE_PREFIX.csr \
			-CA $ROOT_CERT_FILE_PREFIX.pem \
			-CAkey $ROOT_CERT_FILE_PREFIX.key \
			-CAcreateserial \
			-out $SSL_CERT_FILE_PREFIX.pem \
			-sha256 \
			-days 36 \
      -extfile server.ext
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Clean up
#
rm *.csr 2>/dev/null
rm *.srl 2>/dev/null