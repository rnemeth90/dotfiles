#!/bin/bash

namespace=$1
patchValue=$2

if [[ -z $namespace || -z $patchValue ]]; then
  echo "Usage: $0 <namespace> <ingressClassName>"
  exit 1
fi

kubectl get ingress -n "$namespace" -o name | while read -r ingress; do
  echo "Patching $ingress in namespace $namespace with $patchValue"
  kubectl patch "$ingress" -n "$namespace" --type=merge -p "{\"spec\":{\"ingressClassName\":\"$patchValue\"}}"
done
