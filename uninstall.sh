#!/bin/bash

##########################################
# Tear down the cluster and free resources
##########################################

cd "$(dirname "${BASH_SOURCE[0]}")"
./cluster/uninstall.sh
