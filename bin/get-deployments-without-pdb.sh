#!/bin/bash

kubectl get deployments --all-namespaces -o json | jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)"' | while read -r deploy; do 
  ns=$(echo $deploy | cut -d/ -f1); 
  name=$(echo $deploy | cut -d/ -f2); 
  if ! kubectl get pdb -n $ns -o json | jq -e '.items[] | select(.spec.selector.matchLabels."app.kubernetes.io/instance" == "'$name'")' > /dev/null; then 
    echo $deploy; 
  fi; 
done

