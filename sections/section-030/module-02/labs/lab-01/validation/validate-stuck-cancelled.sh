#!/usr/bin/env bash
# PASS when the PipelineRun stuck still exists, has spec.status Cancelled and
# ended with Succeeded=False.
set -uo pipefail

NS="starfleet"

if ! kubectl -n "$NS" get pipelinerun stuck >/dev/null 2>&1; then
  echo "FAIL: PipelineRun stuck does not exist. Cancel it instead of deleting it."
  exit 1
fi

spec="$(kubectl -n "$NS" get pipelinerun stuck -o jsonpath='{.spec.status}')"
if [ "$spec" != "Cancelled" ]; then
  echo "FAIL: PipelineRun stuck has spec.status='${spec}', expected 'Cancelled'."
  exit 1
fi

status=""
for _ in $(seq 1 30); do
  status="$(kubectl -n "$NS" get pipelinerun stuck -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  if [ "$status" = "False" ]; then break; fi
  sleep 3
done
if [ "$status" != "False" ]; then
  echo "FAIL: PipelineRun stuck has Succeeded=${status:-none}, expected False."
  exit 1
fi

echo "PASS: PipelineRun stuck is cancelled and its record is kept."
exit 0
