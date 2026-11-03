#!/usr/bin/env bash
# PASS when the Pipeline roster still has the pipeline tasks write and read
# (with taskRef), and a grader run with two names and its own
# volumeClaimTemplate reports "roster has 2 names, first: alpha". A Pipeline
# that hard-codes the count, or a workspace that is not shared between the
# pods, fails here.
set -uo pipefail

NS="starfleet"

tasks="$(kubectl -n "$NS" get pipeline roster -o jsonpath='{.spec.tasks[*].name}' 2>/dev/null)"
if [ "$tasks" != "write read" ]; then
  echo "FAIL: Pipeline roster must keep the pipeline tasks 'write read' (found '${tasks}')."
  exit 1
fi
refs="$(kubectl -n "$NS" get pipeline roster -o jsonpath='{.spec.tasks[*].taskRef.name}' 2>/dev/null)"
if [ "$refs" != "write-roster read-roster" ]; then
  echo "FAIL: the pipeline tasks must refer to the Tasks 'write-roster read-roster' with taskRef (found '${refs}')."
  exit 1
fi

manifest="$(mktemp)"
trap 'rm -f "$manifest"' EXIT
cat > "$manifest" <<'YAML'
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: roster-grader-
  namespace: starfleet
  labels:
    astrona.io/grader: "true"
spec:
  pipelineRef:
    name: roster
  params:
    - name: crew
      value: "alpha beta"
  workspaces:
    - name: shared
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 16Mi
YAML

name="$(kubectl create -f "$manifest" -o jsonpath='{.metadata.name}' 2>/dev/null)"
if [ -z "$name" ]; then
  echo "FAIL: the grader could not create a PipelineRun of the Pipeline roster."
  exit 1
fi

status=""
for _ in $(seq 1 80); do
  status="$(kubectl -n "$NS" get pipelinerun "$name" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}' 2>/dev/null)"
  [ "$status" = "True" ] || [ "$status" = "False" ] && break
  sleep 3
done
report="$(kubectl -n "$NS" get pipelinerun "$name" -o jsonpath='{.status.results[?(@.name=="report")].value}' 2>/dev/null)"
kubectl -n "$NS" delete pipelinerun "$name" --wait=false >/dev/null 2>&1 || true

if [ "$status" != "True" ]; then
  echo "FAIL: a grader PipelineRun of roster (crew 'alpha beta') did not succeed (Succeeded=${status:-none})."
  exit 1
fi
if [ "$report" != "roster has 2 names, first: alpha" ]; then
  echo "FAIL: a grader run with two names reported '${report}', expected 'roster has 2 names, first: alpha'."
  exit 1
fi

echo "PASS: the Pipeline roster passes the count as a result and the roster in a shared workspace; the grader run reports 'roster has 2 names, first: alpha'."
exit 0
