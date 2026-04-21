#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="${1:-default}"
BACKUP_ANNOTATION="${BACKUP_ANNOTATION:-aprimo.com/original-ingress-class}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required but not installed."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed."
  exit 1
fi

echo "Restoring ingresses in namespace: ${NAMESPACE}"
echo "Source annotation: ${BACKUP_ANNOTATION}"
echo

ingresses_json="$(kubectl get ingress -n "${NAMESPACE}" -o json)"
count="$(echo "${ingresses_json}" | jq '.items | length')"

if [[ "${count}" -eq 0 ]]; then
  echo "No ingresses found in namespace ${NAMESPACE}."
  exit 0
fi

echo "${ingresses_json}" | jq -c '.items[]' | while read -r ingress; do
  name="$(echo "${ingress}" | jq -r '.metadata.name')"

  saved_class="$(echo "${ingress}" | jq -r --arg key "${BACKUP_ANNOTATION}" '
    .metadata.annotations[$key] // empty
  ')"

  if [[ -z "${saved_class}" ]]; then
    echo "Skipping ${name}: annotation '${BACKUP_ANNOTATION}' not found."
    continue
  fi

  current_class="$(echo "${ingress}" | jq -r '.spec.ingressClassName // empty')"

  echo "Restoring ${name}: ingressClassName='${current_class:-<empty>}' -> '${saved_class}'"

  kubectl patch ingress "${name}" \
    -n "${NAMESPACE}" \
    --type merge \
    -p "$(jq -n \
      --arg restored_class "${saved_class}" \
      '{
        spec: {
          ingressClassName: $restored_class
        }
      }')"
done

echo
echo "Done."
