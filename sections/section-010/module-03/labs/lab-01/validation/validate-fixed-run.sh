#!/usr/bin/env bash
# PASS when the TaskRun r-fixed refers to the Task echo-name with taskRef,
# passes name=warp, succeeded, and reports greeting="hello warp".
set -uo pipefail

NS="starfleet"
RUN="r-fixed"

if ! kubectl -n "$NS" get taskrun "$RUN" >/dev/null 2>&1; then
  echo "FAIL: TaskRun $RUN does not exist in $NS."
  exit 1
fi

ref="$(kubectl -n "$NS" get taskrun "$RUN" -o jsonpath='{.spec.taskRef.name}')"
if [ "$ref" != "echo-name" ]; then
  echo "FAIL: TaskRun $RUN must use taskRef name echo-name (found '${ref:-an embedded taskSpec}')."
  exit 1
fi

status=""
for _ in $(seq 1 30); do
  status="$(kubectl -n "$NS" get taskrun "$RUN" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  if [ "$status" = "True" ] || [ "$status" = "False" ]; then break; fi
  sleep 3
done
if [ "$status" != "True" ]; then
  echo "FAIL: TaskRun $RUN has Succeeded=${status:-none}."
  exit 1
fi

greeting="$(kubectl -n "$NS" get taskrun "$RUN" -o jsonpath='{.status.results[?(@.name=="greeting")].value}')"
if [ "$greeting" != "hello warp" ]; then
  echo "FAIL: TaskRun $RUN has the result greeting='${greeting}', expected 'hello warp'."
  exit 1
fi

echo "PASS: TaskRun $RUN uses echo-name, succeeded and reports greeting='hello warp'."
exit 0
