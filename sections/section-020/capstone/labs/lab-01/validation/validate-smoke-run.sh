#!/usr/bin/env bash
# PASS when the Task smoke exists in starfleet and the TaskRun smoke-run
# uses it with crew=probe, succeeded, and reports
# "smoke test passed for probe". A new grader TaskRun must also start and
# succeed, which needs the controller.
set -uo pipefail

NS="starfleet"
TR="smoke-run"

if ! kubectl -n "$NS" get task smoke >/dev/null 2>&1; then
  echo "FAIL: the Task smoke does not exist in $NS."
  exit 1
fi
task_ref="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.spec.taskRef.name}' 2>/dev/null)"
crew="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.spec.params[?(@.name=="crew")].value}' 2>/dev/null)"
if [ "$task_ref" != "smoke" ] || [ "$crew" != "probe" ]; then
  echo "FAIL: TaskRun $TR must use taskRef smoke with crew=probe (found taskRef '${task_ref}', crew '${crew}')."
  exit 1
fi
status="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
message="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.results[?(@.name=="message")].value}')"
if [ "$status" != "True" ] || [ "$message" != "smoke test passed for probe" ]; then
  echo "FAIL: TaskRun $TR has Succeeded=${status:-none} and message='${message}'."
  exit 1
fi

manifest="$(mktemp)"
trap 'rm -f "$manifest"' EXIT
cat > "$manifest" <<'YAML'
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: smoke-grader-
  namespace: starfleet
  labels:
    astrona.io/grader: "true"
spec:
  taskRef:
    name: smoke
  params:
    - name: crew
      value: shuttle
YAML
name="$(kubectl create -f "$manifest" -o jsonpath='{.metadata.name}' 2>/dev/null)"
if [ -z "$name" ]; then
  echo "FAIL: the grader could not create a TaskRun of smoke."
  exit 1
fi
grader_status=""
for _ in $(seq 1 60); do
  grader_status="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}' 2>/dev/null)"
  [ "$grader_status" = "True" ] || [ "$grader_status" = "False" ] && break
  sleep 3
done
kubectl -n "$NS" delete taskrun "$name" --wait=false >/dev/null 2>&1 || true
if [ "$grader_status" != "True" ]; then
  echo "FAIL: a new grader TaskRun of smoke did not succeed (Succeeded=${grader_status:-none}). Is the controller running?"
  exit 1
fi

echo "PASS: smoke-run reports 'smoke test passed for probe', and new TaskRuns start and succeed."
exit 0
