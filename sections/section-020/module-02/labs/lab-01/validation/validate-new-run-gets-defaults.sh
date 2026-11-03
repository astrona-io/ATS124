#!/usr/bin/env bash
# PASS when a new TaskRun of whoami, created by the grader with no pod
# template, reports uid=1000 and has a pod labelled managed-by=starfleet-ci.
# Proves the cluster default works, not a setting in one run.
set -uo pipefail

NS="starfleet"

if [ -n "$(kubectl -n "$NS" get task whoami -o jsonpath='{.spec.stepTemplate.securityContext}{.spec.steps[0].securityContext}' 2>/dev/null)" ]; then
  echo "FAIL: the Task whoami must not set its own securityContext; the default must come from config-defaults."
  exit 1
fi

manifest="$(mktemp)"
trap 'rm -f "$manifest"' EXIT
cat > "$manifest" <<'YAML'
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: whoami-grader-
  namespace: starfleet
  labels:
    astrona.io/grader: "true"
spec:
  taskRef:
    name: whoami
YAML

uid=""
managed=""
for attempt in 1 2 3; do
  name="$(kubectl create -f "$manifest" -o jsonpath='{.metadata.name}' 2>/dev/null)"
  if [ -z "$name" ]; then
    echo "FAIL: the grader could not create a TaskRun of whoami."
    exit 1
  fi
  status=""
  for _ in $(seq 1 40); do
    status="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}' 2>/dev/null)"
    if [ "$status" = "True" ] || [ "$status" = "False" ]; then break; fi
    sleep 3
  done
  uid="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.results[?(@.name=="uid")].value}' 2>/dev/null)"
  pod="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.podName}' 2>/dev/null)"
  managed="$(kubectl -n "$NS" get pod "$pod" -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}' 2>/dev/null)"
  kubectl -n "$NS" delete taskrun "$name" --wait=false >/dev/null 2>&1 || true
  if [ "$uid" = "1000" ] && [ "$managed" = "starfleet-ci" ]; then
    echo "PASS: a new run of whoami reports uid 1000 with the managed-by label starfleet-ci."
    exit 0
  fi
  sleep 5
done

echo "FAIL: a new run of whoami reported uid='${uid}' and managed-by='${managed}', expected 1000 and 'starfleet-ci'."
exit 1
