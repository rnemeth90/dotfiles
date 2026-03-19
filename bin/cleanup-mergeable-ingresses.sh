#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false   # change to false to actually delete

NAMESPACES=(
dam-c013 dam-c014 dam-c015 dam-c016 dam-c017 dam-c018 dam-c023 dam-c030 dam-c031 dam-c032 dam-c034 dam-c035 dam-c036 dam-c037 dam-c038 dam-c039 dam-c041 dam-c042 dam-c043 dam-c044 dam-c045 dam-c048 dam-c049 dam-c102 dam-c111 dam-c112 dam-c113 dam-c114 dam-c120 dam-c121 dam-c122 dam-c124 dam-c126 dam-c129 dam-c163 dam-c170 dam-c171 dam-c260 dam-c261 dam-c285 dam-c290 dam-c291 dam-c292 dam-c293 dam-c295 dam-c303 dam-c311 dam-c312 dam-c313 dam-c314 dam-c315 dam-c317 dam-c318 dam-c319 dam-c325 dam-c326 dam-c327 dam-c328 dam-c329 dam-c330 dam-c331 dam-c342 dam-c343 dam-c344 dam-c345 dam-c350 dam-c351 dam-c352 dam-c353 dam-c354 dam-c359 dam-c360 dam-c371 dam-c372 dam-c373 dam-c390 dam-c391 dam-c392 dam-c393 dam-c394 dam-c395 dam-c481 dam-c482 dam-c483 dam-c484 dam-c485 dam-c502 dam-c504 dam-c506 dam-c507 dam-c508 dam-c510 dam-c512 dam-c514 dam-c517 dam-c520 dam-c521 dam-c523 dam-c524 dam-c551 dam-c552 dam-c553 dam-c562 dam-c579 dam-c663 dam-c665 dam-c667 dam-c668 dam-c669 dam-c700 dam-c711 dam-c713 dam-c714 dam-c715 dam-c717 dam-c718 dam-c720 dam-c722 dam-c723 dam-c725 dam-c726 dam-c729 dam-c730 dam-c731 dam-c732 dam-c733 dam-c734 dam-c735 dam-c736 dam-c737 dam-c738 dam-c739 dam-c740 dam-c741 dam-c742 dam-c743 dam-c744 dam-c745 dam-c746 dam-c747 dam-c748 dam-c749 dam-c750 dam-c751 dam-c752 dam-c753 dam-c754 dam-c765 dam-c766 dam-c767 dam-c768 dam-c769 dam-c776 dam-c777 dam-c778 dam-c779 dam-c785 dam-c786 dam-c787 dam-c789 dam-c790 dam-c791 dam-c792 dam-c795 dam-c796 dam-c797 dam-c798 dam-c799 dam-c809 dam-c810 dam-e110 dam-e120 dam-e130 dam-e140 dam-e150 dam-g125 dam-r930 dam-r940 dam-r950 dam-r960 dam-s910 dam-s920 dam-s930 dam-s940 dam-s950 dam-s960 dam-s970 dam-s980 pm-g011 pm-g016 pm-g042 pm-g045 pm-g128 pm-g311 pm-g312 pm-g319 pm-g522 pm-g737 pm-g751 pm-g754 pm-g790 pm-rtn00 pm-rtn01 pm-rtn02 pm-rtn04 pm-rtn05 pm-rtn19 
)

echo "🔎 Scanning namespaces..."
echo

for ns in "${NAMESPACES[@]}"; do
  echo "▶ Namespace: $ns"

  if ! kubectl get ns "$ns" >/dev/null 2>&1; then
    echo "   ⚠ Namespace does not exist — skipping"
    continue
  fi

  NAMES=$(kubectl get ing -n "$ns" -o json \
    | jq -r '
        .items[]
        | select(
            .metadata.annotations["nginx.org/mergeable-ingress-type"] == "master"
            or
            .metadata.annotations["nginx.org/mergeable-ingress-type"] == "minion"
          )
        | .metadata.name
      ')

  if [[ -z "$NAMES" ]]; then
    echo "   ✅ No mergeable ingresses"
    continue
  fi

  COUNT=$(echo "$NAMES" | wc -l | tr -d ' ')
  echo "   🔥 Found $COUNT mergeable ingresses"

  if $DRY_RUN; then
    echo "$NAMES" | sed 's/^/      /'
  else
    kubectl delete ing -n "$ns" $NAMES --wait=false
  fi

  echo
done

if $DRY_RUN; then
  echo "🧪 DRY RUN complete. Set DRY_RUN=false to execute."
else
  echo "✅ Deletion commands submitted."
fi
