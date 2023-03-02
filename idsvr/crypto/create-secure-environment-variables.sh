#!/bin/bash

##################################################################################################
# A child script to create values to deploy as environment variables to the Curity Identity Server
# A real version would run from a CI / CD server, with access to a secure vault containing secrets
##################################################################################################

cd "$(dirname "${BASH_SOURCE[0]}")"
CURITY_DOCKER_IMAGE='curity.azurecr.io/curity/idsvr:latest'

#
# First run a temporary Curity Docker container that can be called to do crypto work
#
echo 'Downloading the utility idsvr docker container ...'
docker rm -f curity 1>/dev/null 2>&1
docker run -d -p 6749:6749 -e PASSWORD=Password1 --user root --name curity "$CURITY_DOCKER_IMAGE" 1>/dev/null
if [ $? -ne 0 ]; then
  echo '*** Problem encountered starting the Curity docker image'
  exit 1
fi
trap "docker rm -f curity 1>/dev/null 2>&1" EXIT

#
# Wait for its admin node to become available
#
echo 'Waiting for the utility idsvr docker container to come up ...'
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' "https://localhost:6749/admin/login/login.html")" != '200' ]; do
  sleep 2
done

#
# Copy the encryption script to the Docker container
#
docker cp ./encrypt-util.sh curity:/tmp/
docker exec -it curity bash -c 'chmod +x /tmp/encrypt-util.sh'

#
# Get the config encryption key, used to create secure environment variables
#
CONFIG_ENCRYPTION_KEY="$(cat ../../crypto/configencryption.key)"

#
# Get the symmetric key for identity server cookie encryption
#
SYMMETRIC_KEY_RAW="$(cat ../../crypto/symmetric.key)"

#
# Hash the admin password
#
ADMIN_PASSWORD_RAW='Password1'
ADMIN_PASSWORD=$(openssl passwd -5 $ADMIN_PASSWORD_RAW)

#
# Plaintext database details
#
DB_PASSWORD_RAW='Password1'
DB_CONNECTION_RAW='jdbc:postgresql://postgres-svc/idsvr'

#
# Get the token signing key in the Curity format
#
SIGNING_KEY_PASSWORD='Password1'
SIGNING_KEY_BASE64="$(openssl base64 -in ../../crypto/signing.p12 | tr -d '\n')"
SIGNING_KEY_RAW=$(docker exec -it curity bash -c \
    "convertks --in-password $SIGNING_KEY_PASSWORD --in-alias curity.signing --in-entry-password $SIGNING_KEY_PASSWORD --in-keystore $SIGNING_KEY_BASE64")
if [ $? -ne 0 ]; then
  echo "Problem encountered running the convertks command for the signing keypair: $SIGNING_KEY"
  exit 1
fi

#
# Encrypt the token signing key
#
SIGNING_KEY=$(docker exec -it curity bash -c "TYPE=base64keystore PLAINTEXT=$SIGNING_KEY_RAW ENCRYPTIONKEY=$CONFIG_ENCRYPTION_KEY /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "Problem encountered encrypting the token signing key: $SIGNING_KEY"
  exit 1
fi

#
# Use the encryption script to get the encrypted symmetric key
#
SYMMETRIC_KEY=$(docker exec -it curity bash -c "TYPE=plaintext PLAINTEXT=$SYMMETRIC_KEY_RAW ENCRYPTIONKEY=$CONFIG_ENCRYPTION_KEY /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "Problem encountered encrypting the symmetric key: $SYMMETRIC_KEY"
  exit 1
fi

#
# Use the encryption script to get the encrypted DB password
#
DB_PASSWORD=$(docker exec -it curity bash -c "TYPE=plaintext PLAINTEXT=$DB_PASSWORD_RAW ENCRYPTIONKEY=$CONFIG_ENCRYPTION_KEY /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "Problem encountered encrypting the DB password: $DB_PASSWORD"
  exit 1
fi

#
# Use the encryption script to get the encrypted DB connection
#
DB_CONNECTION=$(docker exec -it curity bash -c "TYPE=plaintext PLAINTEXT=$DB_CONNECTION_RAW ENCRYPTIONKEY=$CONFIG_ENCRYPTION_KEY /tmp/encrypt-util.sh")
if [ $? -ne 0 ]; then
  echo "Problem encountered encrypting the DB connection: $DB_CONNECTION"
  exit 1
fi

#
# Create a secret, whose keys are exposed to pods as protected environment variables
#
kubectl -n curity delete secret idsvr-secure-properties
kubectl -n curity create secret generic idsvr-secure-properties \
  --from-literal="ADMIN_PASSWORD=$ADMIN_PASSWORD" \
  --from-literal="DB_PASSWORD=$DB_PASSWORD" \
  --from-literal="DB_CONNECTION=$DB_CONNECTION" \
  --from-literal="SYMMETRIC_KEY=$SYMMETRIC_KEY" \
  --from-literal="SIGNING_KEY=$SIGNING_KEY"
if [ $? -ne 0 ]; then
  echo "Problem encountered creating the Kubernetes secret containing secure environment variables"
  exit 1
fi