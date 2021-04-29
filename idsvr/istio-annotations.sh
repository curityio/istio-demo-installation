#!/bin/bash

##############################################################################################
# Dynamically apply Istio annotations to Kubernetes YAML files, which requires some hacky code
##############################################################################################

#
# A command line parameter indicates whether to use sidecars, so that we can test both setups
#
USE_ISTIO_SIDECARS=$1

#
# Split the Helm chart YAML into individual files
#
mkdir -p yaml
cd yaml
cat ../idsvr-helm.yaml | awk '/---/{f=NR".yaml"}; {print > f}'

#
# Get each yaml file into an array, sorted in a numeric sequence
# The last 3 files are those we will exclude from using a sidecar proxy
#
FILES=($(ls | sort -n))
LENGTH=${#FILES[@]}
CONF_JOB=${FILES[LENGTH - 1]}
RUNTIME_DEPLOYMENT=${FILES[LENGTH - 2]}
ADMIN_DEPLOYMENT=${FILES[LENGTH - 3]}

#
# Run yq to set the annotation, and note that sidecars are always disabled for the conf job, to prevent this error:
#
# 1- 39906036158912:error:0200206F:system library:connect:Connection refused:../crypto/bio/b_sock2.c:110:
# - 139906036158912:error:2008A067:BIO routines:BIO_connect:connect error:../crypto/bio/b_sock2.c:111:
# - connect:errno=111
#
yq e ".spec.template.metadata.annotations.\"sidecar.istio.io/inject\" = \"false\"" -i $CONF_JOB
yq e ".spec.template.metadata.annotations.\"sidecar.istio.io/inject\" = \"$USE_ISTIO_SIDECARS\"" -i $RUNTIME_DEPLOYMENT
yq e ".spec.template.metadata.annotations.\"sidecar.istio.io/inject\" = \"$USE_ISTIO_SIDECARS\"" -i $ADMIN_DEPLOYMENT

#
# Concatenate all files in sequence
#
FINAL_FILE=../idsvr-final.yaml
rm $FINAL_FILE 2>/dev/null
touch $FINAL_FILE
for file in "${FILES[@]}"; do
  data="$(cat $file)"
  
  # For some reason the awk output does not write the --- separator for some files
  if ! [[ $data == ---* ]] ; then
    echo '---' >> $FINAL_FILE
  fi

  echo "$data" >> $FINAL_FILE
done

#
# Clean up temporary files and return to the main script
#
cd ..
rm -rf yaml

