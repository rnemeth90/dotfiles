#!/usr/bin/env bash

set -euo pipefail

# Optional: pass a namespace to limit the scan. With no arguments, every namespace is checked.
NAMESPACE_ARG="${1:-}"
BACKUP_ANNOTATION="${BACKUP_ANNOTATION:-aprimo.com/original-ingress-class}"
NEW_CLASS_NAME="${NEW_CLASS_NAME:-invalid}"
# Only minion ingresses using this class are patched (spec.ingressClassName or legacy annotation).
TARGET_INGRESS_CLASS="${TARGET_INGRESS_CLASS:-lab-pm-public-nginx-pm-r09}"
MINION_ANNOTATION_KEY="${MINION_ANNOTATION_KEY:-nginx.org/mergeable-ingress-type}"
MINION_ANNOTATION_VALUE="${MINION_ANNOTATION_VALUE:-minion}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required but not installed."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed."
  exit 1
fi

if [[ -n "${NAMESPACE_ARG}" ]] && ! kubectl get ns "${NAMESPACE_ARG}" >/dev/null 2>&1; then
  echo "Namespace '${NAMESPACE_ARG}' does not exist or is not accessible."
  exit 1
fi

list_namespaces() {
  if [[ -n "${NAMESPACE_ARG}" ]]; then
    echo "${NAMESPACE_ARG}"
    return
  fi
  kubectl get ns -o json | jq -r '.items[].metadata.name'
}

running_pod_count() {
  local ns="$1"
  kubectl get pods -n "${ns}" --field-selector=status.phase=Running -o json \
    | jq '.items | length'
}

patch_minion_ingress() {
  local ns="$1"
  local name="$2"
  local class_name="$3"

  echo "Updating ${ns}/${name}: class='${class_name}' -> '${NEW_CLASS_NAME}'"

  kubectl patch ingress "${name}" \
    -n "${ns}" \
    --type merge \
    -p "$(jq -n \
      --arg annotation_key "${BACKUP_ANNOTATION}" \
      --arg annotation_val "${class_name}" \
      --arg new_class "${NEW_CLASS_NAME}" \
      '{
        metadata: {
          annotations: {
            ($annotation_key): $annotation_val
          }
        },
        spec: {
          ingressClassName: $new_class
        }
      }')"
}

echo "Scanning namespaces for minion ingresses (${MINION_ANNOTATION_KEY}=${MINION_ANNOTATION_VALUE})"
echo "with ingress class '${TARGET_INGRESS_CLASS}'."
echo "Namespaces with any Running pods are skipped."
if [[ -n "${NAMESPACE_ARG}" ]]; then
  echo "Limited to namespace: ${NAMESPACE_ARG}"
else
  echo "All namespaces (pass one name as \$1 to limit)."
fi
echo "Backup annotation: ${BACKUP_ANNOTATION}"
echo "New ingressClassName: ${NEW_CLASS_NAME}"
echo

while read -r ns; do
  [[ -z "${ns}" ]] && continue

  if ! kubectl get ns "${ns}" >/dev/null 2>&1; then
    echo "Skipping ${ns}: namespace not found."
    continue
  fi

  running="$(running_pod_count "${ns}")"
  if [[ "${running}" -gt 0 ]]; then
    continue
  fi

  ingresses_json="$(kubectl get ingress -n "${ns}" -o json)"
  minions_json="$(echo "${ingresses_json}" | jq \
    --arg k "${MINION_ANNOTATION_KEY}" \
    --arg v "${MINION_ANNOTATION_VALUE}" \
    --arg target "${TARGET_INGRESS_CLASS}" '
    .items
    | map(select(
        (.metadata.annotations[$k] // "") == $v
        and (
          (.spec.ingressClassName // "") == $target
          or ((.metadata.annotations["kubernetes.io/ingress.class"] // "") == $target)
        )
      ))
  ')"
  minion_count="$(echo "${minions_json}" | jq 'length')"

  if [[ "${minion_count}" -eq 0 ]]; then
    continue
  fi

  echo "Namespace ${ns}: ${running} Running pod(s), ${minion_count} minion ingress(es) with class '${TARGET_INGRESS_CLASS}'"

  echo "${minions_json}" | jq -c '.[]' | while read -r ingress; do
    name="$(echo "${ingress}" | jq -r '.metadata.name')"

    class_name="$(echo "${ingress}" | jq -r '
      .spec.ingressClassName //
      .metadata.annotations["kubernetes.io/ingress.class"] //
      empty
    ')"

    if [[ -z "${class_name}" ]]; then
      echo "Skipping ${ns}/${name}: no ingress class found."
      continue
    fi

    patch_minion_ingress "${ns}" "${name}" "${class_name}"
  done
  echo
done < <(list_namespaces)

echo "Done."
