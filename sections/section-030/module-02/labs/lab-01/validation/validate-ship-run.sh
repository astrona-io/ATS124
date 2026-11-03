#!/usr/bin/env bash
# PASS when a PipelineRun named ship-* of the Pipeline deliver succeeded with
# the result summary=orbit:v1.
set -uo pipefail

NS="starfleet"

run="$(kubectl -n "$NS" get pipelineruns -l tekton.dev/pipeline=deliver -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep '^ship' | head -n 1)"
if [ -z "$run" ]; then
  echo "FAIL: no PipelineRun of deliver has a name starting with ship."
  exit 1
fi

status=""
for _ in $(seq 1 40); do
  status="$(kubectl -n "$NS" get pipelinerun "$run" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  if [ "$status" = "True" ] || [ "$status" = "False" ]; then break; fi
  sleep 3
done
if [ "$status" != "True" ]; then
  echo "FAIL: PipelineRun $run has Succeeded=${status:-none}."
  exit 1
fi

summary="$(kubectl -n "$NS" get pipelinerun "$run" -o jsonpath='{.status.results[?(@.name=="summary")].value}')"
if [ "$summary" != "orbit:v1" ]; then
  echo "FAIL: PipelineRun $run has summary='${summary}', expected 'orbit:v1'."
  exit 1
fi

echo "PASS: PipelineRun $run succeeded with summary orbit:v1."
exit 0
