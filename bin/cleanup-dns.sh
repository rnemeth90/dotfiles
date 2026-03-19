#!/usr/bin/env bash
set -euo pipefail

ZONE="labs.aprimo.com"
RESOURCE_GROUP="network-dns-prod-rg"
TARGET_IP="52.191.221.175"
TARGET_INGRESS_CLASS="lab-dam-public-nginx-dam-c900"

LIMIT=""
DRY_RUN="false"

usage() {
  cat <<EOF
Usage: $0 --limit <number> [--dry-run <true|false>]

Options:
  --limit      Number of namespaces to delete records for in this run
  --dry-run    true or false (default: false)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$LIMIT" ]]; then
  echo "Error: --limit is required"
  exit 1
fi

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]] || [[ "$LIMIT" -le 0 ]]; then
  echo "Error: --limit must be a positive integer"
  exit 1
fi

if [[ "$DRY_RUN" != "true" && "$DRY_RUN" != "false" ]]; then
  echo "Error: --dry-run must be true or false"
  exit 1
fi

candidate_records() {
  az network dns record-set a list \
    -z "$ZONE" \
    -g "$RESOURCE_GROUP" \
    --query "[?ARecords[?ipv4Address=='$TARGET_IP']].name" \
    -o tsv
}

record_exists() {
  local record="$1"
  az network dns record-set a show \
    -z "$ZONE" \
    -g "$RESOURCE_GROUP" \
    -n "$record" \
    >/dev/null 2>&1
}

delete_record() {
  local record="$1"

  if ! record_exists "$record"; then
    echo "  [SKIP RECORD] $record -> not found"
    return
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [DRY-RUN DELETE RECORD] $record"
  else
    echo "  [DELETE RECORD] $record"
    az network dns record-set a delete \
      -z "$ZONE" \
      -g "$RESOURCE_GROUP" \
      -n "$record" \
      --yes
  fi
}

records_for_suffix() {
  local suffix="$1"

  printf '%s\n' \
    "apiauto${suffix}" \
    "excelsiorauto${suffix}" \
    "${suffix}-financial1" \
    "${suffix}-financial2" \
    "us1-${suffix}"
    "us1-${suffix}.dam"
}

echo "LIMIT=$LIMIT namespace deletion(s)"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "MODE=DRY-RUN"
else
  echo "MODE=DELETE"
fi
echo

scanned_records=0
matched_namespaces=0

deleted_namespaces=()
kept=()
skipped=()

while IFS= read -r record; do
  [[ -z "$record" ]] && continue

  if [[ "$matched_namespaces" -ge "$LIMIT" ]]; then
    break
  fi

  if [[ "$record" != apiauto* ]]; then
    continue
  fi

  scanned_records=$((scanned_records + 1))

  suffix="${record#apiauto}"
  namespace="dam-$suffix"

  if ! kubectl get namespace "$namespace" >/dev/null 2>&1; then
    echo "[SKIP] $record -> namespace $namespace not found"
    skipped+=("$record|$namespace|namespace-missing")
    continue
  fi

  matching_ingresses="$(
    kubectl get ingress -n "$namespace" -o json \
    | jq -r --arg cls "$TARGET_INGRESS_CLASS" '
        .items[]
        | select(.spec.ingressClassName == $cls)
        | .metadata.name
      ' 2>/dev/null || true
  )"

  if [[ -n "$matching_ingresses" ]]; then
    matched_namespaces=$((matched_namespaces + 1))
    ingress_csv="$(printf '%s\n' "$matching_ingresses" | tr '\n' ',' | sed 's/,$//')"

    echo "[MATCH] $record -> namespace=$namespace ingresses=$ingress_csv"
    echo "  Related DNS records for suffix $suffix:"

    while IFS= read -r related_record; do
      delete_record "$related_record"
    done < <(records_for_suffix "$suffix")

    deleted_namespaces+=("$namespace")
  else
    echo "[KEEP] $record -> namespace=$namespace has no ingress using $TARGET_INGRESS_CLASS"
    kept+=("$record")
  fi
done < <(candidate_records)

echo
echo "===== SUMMARY ====="
echo "Seed records scanned:         $scanned_records"
echo "Matched namespaces:           $matched_namespaces"
echo "Kept:                         ${#kept[@]}"
echo "Skipped:                      ${#skipped[@]}"

if [[ ${#deleted_namespaces[@]} -gt 0 ]]; then
  echo
  echo "Matched namespaces:"
  printf '%s\n' "${deleted_namespaces[@]}"
fi

if [[ ${#kept[@]} -gt 0 ]]; then
  echo
  echo "Kept records:"
  printf '%s\n' "${kept[@]}"
fi

if [[ ${#skipped[@]} -gt 0 ]]; then
  echo
  echo "Skipped records:"
  printf '%s\n' "${skipped[@]}"
fi

