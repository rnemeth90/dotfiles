#!/bin/bash

set -e

nodes=$(kubectl get nodes --no-headers | awk '{print $1}')
for n in ${nodes[@]}; do
  pods=$(kubectl get pod -A --field-selector spec.nodeName=$n --no-headers | awk '{print $2}')
  echo $n = $(echo $pods | wc -w)
done