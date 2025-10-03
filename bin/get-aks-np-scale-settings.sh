#!/usr/bin/env bash
# get-aks-nodepool-scale.sh
# Usage: ./get-aks-nodepool-scale.sh <resource-group> <cluster-name>
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <resource-group> <cluster-name>" >&2
  exit 1
fi

RG="$1"
CLUSTER="$2"

# Requires: Azure CLI (az) logged in and correct subscription selected.
az aks nodepool list \
  --resource-group "$RG" \
  --cluster-name "$CLUSTER" \
  --query 'sort_by([].{
      Pool:name,
      Mode:mode,
      Autoscaling:enableAutoScaling,
      Min:minCount,
      Max:maxCount
    }, &Pool)' \
  -o table
