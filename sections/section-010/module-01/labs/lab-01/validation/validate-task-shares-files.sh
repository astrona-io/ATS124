#!/usr/bin/env bash
# PASS when the Task preflight still has the two steps collect and verify,
# and verify really counts what collect wrote: the grader runs the Task with
# four checks and expects "probe: 4 checks passed". A Task that hard-codes the
# count, or merges the two steps, fails here.
set -uo pipefail

NS="starfleet"

steps="$(kubectl -n "$NS" get task preflight -o jsonpath='{.spec.steps[*].name}' 2>/dev/null)"
if [ "$steps" != "collect verify" ]; then
  echo "FAIL: Task preflight must keep the two steps 'collect verify' (found '${steps}')."
  exit 1
fi

manifest="$(mktemp)"
trap 'rm -f "$manifest"' EXIT
cat > "$manifest" <<'YAML'
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: preflight-grader-
  namespace: starfleet
  labels:
    astrona.io/grader: "true"
spec:
  taskRef:
    name: preflight
  params:
    - name: target
      value: probe
    - name: checks
      value: "alpha beta gamma delta"
YAML

name="$(kubectl create -f "$manifest" -o jsonpath='{.metadata.name}' 2>/dev/null)"
if [ -z "$name" ]; then
  echo "FAIL: the grader could not create a TaskRun of the Task preflight."
  exit 1
fi

status=""
for _ in $(seq 1 60); do
  status="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}' 2>/dev/null)"
  [ "$status" = "True" ] || [ "$status" = "False" ] && break
  sleep 3
done
summary="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.results[?(@.name=="summary")].value}' 2>/dev/null)"
kubectl -n "$NS" delete taskrun "$name" --wait=false >/dev/null 2>&1 || true

if [ "$status" != "True" ]; then
  echo "FAIL: a grader TaskRun of preflight (target=probe, four checks) did not succeed (Succeeded=${status:-none})."
  exit 1
fi
if [ "$summary" != "probe: 4 checks passed" ]; then
  echo "FAIL: a grader TaskRun with four checks reported '${summary}', expected 'probe: 4 checks passed'. The step verify must count what collect wrote."
  exit 1
fi

echo "PASS: the steps collect and verify share their file; a grader run with four checks reports 'probe: 4 checks passed'."
exit 0
