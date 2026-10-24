#!/usr/bin/env bash
# PASS when the TaskRun inspect-run uses the Task inspect with target=scout,
# succeeded, ran one container per step in the order scan, summarize, report,
# and reports "scout: 3 findings, status green".
set -uo pipefail

NS="starfleet"
TR="inspect-run"
EXPECTED="scout: 3 findings, status green"

if ! kubectl -n "$NS" get taskrun "$TR" >/dev/null 2>&1; then
  echo "FAIL: TaskRun $TR does not exist in $NS."
  exit 1
fi
task_ref="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.spec.taskRef.name}')"
if [ "$task_ref" != "inspect" ]; then
  echo "FAIL: TaskRun $TR must use taskRef name inspect (found '${task_ref:-an embedded taskSpec}')."
  exit 1
fi
target="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.spec.params[?(@.name=="target")].value}')"
if [ "$target" != "scout" ]; then
  echo "FAIL: TaskRun $TR must pass target=scout (found '${target}')."
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

pod="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.podName}')"
containers="$(kubectl -n "$NS" get pod "${pod:-none}" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)"
if [ "$containers" != "step-scan step-summarize step-report" ]; then
  echo "FAIL: the pod of $TR must have the containers 'step-scan step-summarize step-report' (found '${containers}')."
  exit 1
fi

report="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.results[?(@.name=="report")].value}')"
if [ "$report" != "$EXPECTED" ]; then
  echo "FAIL: TaskRun $TR reports '${report}', expected '$EXPECTED'."
  exit 1
fi

echo "PASS: TaskRun $TR succeeded with one container per step and reports '$EXPECTED'."
exit 0
