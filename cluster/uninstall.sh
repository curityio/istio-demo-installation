#!/bin/bash

###############################################
# Tear down the KIND cluster and free resources
###############################################

cd "$(dirname "${BASH_SOURCE[0]}")"
kind delete cluster --name=curity
