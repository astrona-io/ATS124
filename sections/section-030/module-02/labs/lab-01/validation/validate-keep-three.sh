#!/usr/bin/env bash
# PASS when exactly three PipelineRuns of deliver remain: one named ship-*,
# deliver-old-4 and deliver-old-5.
set -uo pipefail

NS="starfleet"

names="$(kubectl -n "$NS" get pipelineruns -l tekton.dev/pipeline=deliver -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | sort)"
count="$(printf '%s\n' "$names" | grep -c .)"
if [ "$count" != "3" ]; then
  echo "FAIL: $count PipelineRuns of deliver remain, expected 3:"
  printf '%s\n' "$names"
  exit 1
fi

for keep in deliver-old-4 deliver-old-5; do
  if ! printf '%s\n' "$names" | grep -qx "$keep"; then
    echo "FAIL: $keep must remain; it is one of the newest runs."
    exit 1
  fi
done

if ! printf '%s\n' "$names" | grep -q '^ship'; then
  echo "FAIL: the run whose name starts with ship must remain."
  exit 1
fi

echo "PASS: the ship run, deliver-old-4 and deliver-old-5 remain."
exit 0
