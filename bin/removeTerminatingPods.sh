#!/bin/bash

set -e

namespace="cip-r01"
# selector="app.kubernetes.io/instance=dam-syncsvc-c110"
pods=$(kubectl get pods -n ${namespace} -l ${selector} | egrep -i 'terminating' | awk '{print $1 }')
for i in ${pods[@]}; do
  kubectl delete pod --force=true --wait=false --grace-period=0 $i -n ${namespace}
done

