#!/usr/bin/env bash
# PASS when the TaskRun preflight-run in starfleet refers to the Task
# preflight (not an embedded taskSpec), passes target=bridge, ran the steps
# collect and verify in that order, and succeeded.
set -uo pipefail

NS="starfleet"
TR="preflight-run"

if ! kubectl -n "$NS" get taskrun "$TR" >/dev/null 2>&1; then
  echo "FAIL: TaskRun $TR does not exist in $NS."
  exit 1
fi

task_ref="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.spec.taskRef.name}')"
if [ "$task_ref" != "preflight" ]; then
  echo "FAIL: TaskRun $TR must use taskRef name preflight (found '${task_ref:-an embedded taskSpec}')."
  exit 1
fi

target="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.spec.params[?(@.name=="target")].value}')"
if [ "$target" != "bridge" ]; then
  echo "FAIL: TaskRun $TR must pass the parameter target=bridge (found '${target}')."
  exit 1
fi

status=""
for _ in $(seq 1 20); do
  status="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  [ "$status" = "True" ] || [ "$status" = "False" ] && break
  sleep 3
done
if [ "$status" != "True" ]; then
  reason="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].reason}')"
  echo "FAIL: TaskRun $TR has Succeeded=${status:-none} (reason: ${reason:-none})."
  exit 1
fi

steps="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.steps[*].name}')"
if [ "$steps" != "collect verify" ]; then
  echo "FAIL: TaskRun $TR must run the steps 'collect verify' in that order (found '$steps')."
  exit 1
fi

echo "PASS: TaskRun $TR uses the Task preflight with target=bridge, ran collect then verify, and succeeded."
exit 0
