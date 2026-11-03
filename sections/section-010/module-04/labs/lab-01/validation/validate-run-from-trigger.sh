#!/usr/bin/env bash
# PASS when a PipelineRun named from-trigger-* ran the Pipeline deliver with
# target=orbit and succeeded.
set -uo pipefail

NS="starfleet"

run="$(kubectl -n "$NS" get pipelineruns -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep '^from-trigger-' | head -n 1)"
if [ -z "$run" ]; then
  echo "FAIL: no PipelineRun has a name starting with from-trigger-. Send the request to the listener."
  exit 1
fi

ref="$(kubectl -n "$NS" get pipelinerun "$run" -o jsonpath='{.spec.pipelineRef.name}')"
if [ "$ref" != "deliver" ]; then
  echo "FAIL: $run uses the Pipeline '${ref}', expected deliver."
  exit 1
fi

target="$(kubectl -n "$NS" get pipelinerun "$run" -o jsonpath='{.spec.params[?(@.name=="target")].value}')"
if [ "$target" != "orbit" ]; then
  echo "FAIL: $run has target='${target}', expected orbit."
  exit 1
fi

status=""
for _ in $(seq 1 40); do
  status="$(kubectl -n "$NS" get pipelinerun "$run" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  if [ "$status" = "True" ] || [ "$status" = "False" ]; then break; fi
  sleep 3
done
if [ "$status" != "True" ]; then
  echo "FAIL: $run has Succeeded=${status:-none}."
  exit 1
fi

echo "PASS: $run was created by the listener and succeeded with target orbit."
exit 0
