#!/usr/bin/env bash
# PASS when the PipelineRun roster-run refers to the Pipeline roster (not an
# embedded pipelineSpec), passes crew="bridge scout probe", has TaskRuns for
# the pipeline tasks write and read, and succeeded.
set -uo pipefail

NS="starfleet"
PR="roster-run"

if ! kubectl -n "$NS" get pipelinerun "$PR" >/dev/null 2>&1; then
  echo "FAIL: PipelineRun $PR does not exist in $NS."
  exit 1
fi

ref="$(kubectl -n "$NS" get pipelinerun "$PR" -o jsonpath='{.spec.pipelineRef.name}')"
if [ "$ref" != "roster" ]; then
  echo "FAIL: PipelineRun $PR must use pipelineRef name roster (found '${ref:-an embedded pipelineSpec}')."
  exit 1
fi

crew="$(kubectl -n "$NS" get pipelinerun "$PR" -o jsonpath='{.spec.params[?(@.name=="crew")].value}')"
if [ "$crew" != "bridge scout probe" ]; then
  echo "FAIL: PipelineRun $PR must pass crew='bridge scout probe' (found '${crew}')."
  exit 1
fi

status=""
for _ in $(seq 1 30); do
  status="$(kubectl -n "$NS" get pipelinerun "$PR" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  [ "$status" = "True" ] || [ "$status" = "False" ] && break
  sleep 3
done
if [ "$status" != "True" ]; then
  reason="$(kubectl -n "$NS" get pipelinerun "$PR" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].reason}')"
  echo "FAIL: PipelineRun $PR has Succeeded=${status:-none} (reason: ${reason:-none})."
  exit 1
fi

tasks="$(kubectl -n "$NS" get pipelinerun "$PR" -o jsonpath='{range .status.childReferences[*]}{.pipelineTaskName}{"\n"}{end}' | sort | tr '\n' ' ')"
if [ "$tasks" != "read write " ]; then
  echo "FAIL: PipelineRun $PR must have TaskRuns for the pipeline tasks read and write (found '${tasks}')."
  exit 1
fi

echo "PASS: PipelineRun $PR uses the Pipeline roster, has TaskRuns for write and read, and succeeded."
exit 0
