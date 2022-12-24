#!/bin/bash

set -e

kubectl get --no-headers pods --all-namespaces -o wide > /tmp/allpods
while read node; do
    echo "${node/node\//}"
    while read line; do
        set -- $line
        echo " $2 $4"
    done < <(grep " ${node/node\//} " /tmp/allpods)
done < <(kubectl get nodes --no-headers --output=name) | column -t -s ' '
