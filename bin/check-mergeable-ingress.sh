#!/usr/bin/env bash

set -euo pipefail

CLASS="lab-pm-public-nginx-pm-r09"

echo "🔎 Fetching ingresses for class: $CLASS"
echo

kubectl get ingress -A -o json \
| jq -r --arg CLASS "$CLASS" '

  #############################################
  # Helpers
  #############################################

  def hosts:
    if .spec.rules then
      [.spec.rules[].host // empty]
    else
      []
    end;

  def type:
    .metadata.annotations["nginx.org/mergeable-ingress-type"];

  #############################################
  # Filter to only ingresses in this class
  #############################################

  .items
  | map(select(.spec.ingressClassName == $CLASS))
  as $all

  |

  #############################################
  # Build master map: ns|host → master info
  #############################################

  (
    $all
    | map(select(type == "master"))
    | reduce .[] as $m ({}; 
        reduce ($m | hosts[]) as $h (.;
          .[$m.metadata.namespace + "|" + $h] = {
            name: $m.metadata.name,
            tls: ($m.spec.tls // [])
          }
        )
      )
  ) as $master_map

  |

  #############################################
  # Build minion map: ns|host → [minions]
  #############################################

  (
    $all
    | map(select(type == "minion"))
    | reduce .[] as $min ({}; 
        reduce ($min | hosts[]) as $h (.;
          .[$min.metadata.namespace + "|" + $h] += [
            $min.metadata.name
          ]
        )
      )
  ) as $minion_map

  |

  #############################################
  # Collect problems
  #############################################

  (
    # Masters
    $master_map
    | to_entries[]
    | .key as $key
    | .value as $m
    | ($key | split("|")) as [$ns, $host]
    |
    (
      if ($m.tls | length) == 0 then
        "❌ MASTER missing TLS: \($ns)/\($m.name) host=\($host)"
      else empty end
    ),
    (
      if ($minion_map[$key] == null) then
        "⚠ MASTER has no minions: \($ns)/\($m.name) host=\($host)"
      else empty end
    )
  ),

  (
    # Minions
    $minion_map
    | to_entries[]
    | .key as $key
    | .value as $minions
    | ($key | split("|")) as [$ns, $host]
    |
    if ($master_map[$key] == null) then
      $minions[]
      | "❌ MINION without MASTER: \($ns)/\(.) host=\($host)"
    else empty end
  )

' | sort -u

echo
echo "✅ Check complete."
