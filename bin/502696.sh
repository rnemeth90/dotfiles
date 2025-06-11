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
ipAddress=$(kubectl get service -n ${namespace} lab-proxy-"$labId" -ojsonpath='{.spec.externalName}')
echo "[INFO] labIpAddr: ${ipAddress}"
port=$(kubectl get service -n ${namespace} lab-proxy-"$labId" -ojsonpath='{.spec.ports[*].port}')
echo "[INFO] port: ${port}"

echo "[INFO] backing up externalName service for namespace: ${namespace}"
mkdir -p /tmp/backups
kubectl get service -n ${namespace} --field-selector spec.type=ExternalName -oyaml > /tmp/backups/lab-proxy-"$labId".yaml

serviceName=lab-proxy-${labId}
svcType=$(kubectl get service -n "${namespace}" "${serviceName}" -o jsonpath='{.spec.type}')
if [ "$svcType" = "ExternalName" ]; then
  echo "[INFO] deleting ExternalName service: ${serviceName}"
  kubectl delete service -n "${namespace}" "${serviceName}"
else
  echo "[INFO] ${serviceName} is not of type ExternalName, skipping delete"
fi

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
  name: lab-proxy-${labId}
  namespace: ${namespace}
spec:
  ports:
    - port: ${port}
      targetPort: ${port}
      protocol: TCP
      name: https
  clusterIP: None
EOF

