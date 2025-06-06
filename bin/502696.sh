#!/bin/bash

namespace=$1

usage() {
  echo "example: ${0} pm-rtn01"
  exit 0
}

if [ -z "$namespace" ]; then
  echo "[ERROR] namespace is required"
  usage
fi

labId=$(echo "$namespace" | awk -F'-' '{print $2}')
echo "[INFO] labId: ${labId}"
ipAddress=$(kubectl get service lab-proxy-"$labId" -ojsonpath='{.spec.externalName}')
echo "[INFO] labIpAddr: ${ipAddress}"
port=$(kubectl get service lab-proxy-"$labId" -ojsonpath='{.spec.ports[*].port}')
echo "[INFO] port: ${port}"

echo "[INFO] creating service and endpoint for namespace: ${namespace}"
kubectl create -f - <<EOF
apiVersion: v1
kind: Endpoints
metadata:
  name: lab-proxy-endpoint
  namespace: ${namespace}
subsets:
  - addresses:
      - ip: ${ipAddress}
    ports:
      - port: ${port}
---
apiVersion: v1
kind: Service
metadata:
  name: lab-proxy-service
  namespace: ${namespace}
spec:
  ports:
    - port: ${port}
      targetPort: ${port}
      protocol: TCP
      name: https
  clusterIP: None
EOF

echo "[INFO] delete externalName service for namespace: ${namespace}"
kubectl delete $(kubectl get service --field-selector spec.type=ExternalName -o name)
