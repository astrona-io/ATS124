#!/usr/bin/env bash
# PASS when the TaskRun install-check-run in starfleet uses the Task
# install-check, picked up the new defaults, succeeded and reports status=ok.
set -uo pipefail

NS="starfleet"
TR="install-check-run"

if ! kubectl -n "$NS" get taskrun "$TR" >/dev/null 2>&1; then
  echo "FAIL: TaskRun $TR does not exist in $NS."
  exit 1
fi
task_ref="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.spec.taskRef.name}')"
if [ "$task_ref" != "install-check" ]; then
  echo "FAIL: TaskRun $TR must use taskRef name install-check (found '${task_ref:-an embedded taskSpec}')."
  exit 1
fi
timeout="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.spec.timeout}')"
sa="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.spec.serviceAccountName}')"
if [ "$timeout" != "20m0s" ] || [ "$sa" != "default" ]; then
  echo "FAIL: TaskRun $TR has timeout '${timeout}' and ServiceAccount '${sa}'. Create it after fixing config-defaults, so it gets 20m0s and default."
  exit 1
fi
status="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
result="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.results[?(@.name=="status")].value}')"
if [ "$status" != "True" ] || [ "$result" != "ok" ]; then
  echo "FAIL: TaskRun $TR has Succeeded=${status:-none} and result status='${result}'."
  exit 1
fi
echo "PASS: TaskRun $TR ran with the new defaults and reports status=ok."
exit 0
