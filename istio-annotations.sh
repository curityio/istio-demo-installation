#!/bin/bash

########################################################################
# A hack to dynamically apply Istio annotations to Kubernetes YAML files
########################################################################

#
# Split the Helm chart YAML into individual files
#
mkdir -p idsvr/yaml
cd idsvr/yaml
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
# Run yq on each of them to set the annotation
#
yq e '.spec.template.metadata.annotations."sidecar.istio.io/inject" = "false"' -i $CONF_JOB
yq e '.spec.template.metadata.annotations."sidecar.istio.io/inject" = "false"' -i $RUNTIME_DEPLOYMENT
yq e '.spec.template.metadata.annotations."sidecar.istio.io/inject" = "false"' -i $ADMIN_DEPLOYMENT

#
# Concatenate all files in sequence
#
FINAL_FILE=../idsvr-final.yaml
rm $FINAL_FILE
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
cd ..

