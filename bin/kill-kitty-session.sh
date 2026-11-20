#!/usr/bin/env bash
set -euo pipefail

mapfile -t pids < <(
  ps -eo pid=,stat=,comm= |
    awk '$3 == "kitty" && $2 !~ /^Z/ { print $1 }'
)

if ((${#pids[@]} == 0)); then
  echo "No live Kitty sessions found."
  exit 0
fi

echo "Live Kitty sessions:"
for i in "${!pids[@]}"; do
  pid=${pids[$i]}
  printf '  %d) PID %s: ' "$((i + 1))" "$pid"
  ps -p "$pid" -o args= || true
done

read -r -p "Select a session to terminate: " choice
if [[ ! $choice =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#pids[@]})); then
  echo "Invalid selection." >&2
  exit 1
fi

pid=${pids[$((choice - 1))]}
identity=$(ps -p "$pid" -o comm=,stat= 2>/dev/null || true)
read -r comm state <<<"$identity"
if [[ $comm != kitty || $state == Z* ]]; then
  echo "Selected Kitty session is no longer running." >&2
  exit 1
fi

kill -TERM "$pid"
for _ in {1..5}; do
  sleep 1
  identity=$(ps -p "$pid" -o comm=,stat= 2>/dev/null || true)
  read -r comm state <<<"$identity" || true
  if [[ $comm != kitty || $state == Z* ]]; then
    echo "Kitty session PID $pid terminated."
    exit 0
  fi
done

identity=$(ps -p "$pid" -o comm=,stat= 2>/dev/null || true)
read -r comm state <<<"$identity" || true
if [[ $comm == kitty && $state != Z* ]]; then
  kill -KILL "$pid"
  echo "Kitty session PID $pid force-stopped."
else
  echo "Kitty session PID $pid terminated."
fi
