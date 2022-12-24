#!/bin/bash

set -e

POD=$1

if [ -z $POD ]
then
  printf "Provide a pod name at args[1]"
else
  NODE=$(kubectl get pod -A -o wide | grep -i $POD | awk '{print $8}')
  kubectl exec -it $(kubectl get pod -n core-dump-handler -o wide | grep -i $NODE | awk '{print $1}') -n core-dump-handler -- cmd /c 'nslookup dev.azure.com'
fi
