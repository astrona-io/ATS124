#!/usr/bin/env bash
# PASS when a new TaskRun that sets no timeout and no ServiceAccount gets
# spec.timeout 20m0s and spec.serviceAccountName default, and succeeds.
# Rejects the shortcut of creating the ServiceAccount tekton-builder.
set -uo pipefail

NS="starfleet"

if kubectl -n "$NS" get serviceaccount tekton-builder >/dev/null 2>&1; then
  echo "FAIL: the ServiceAccount tekton-builder exists in $NS. The team wants runs without a ServiceAccount to use 'default'; fix config-defaults instead."
  exit 1
fi

manifest="$(mktemp)"
trap 'rm -f "$manifest"' EXIT
cat > "$manifest" <<'YAML'
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: defaults-grader-
  namespace: starfleet
  labels:
    astrona.io/grader: "true"
spec:
  taskRef:
    name: install-check
YAML

name="$(kubectl create -f "$manifest" -o jsonpath='{.metadata.name}' 2>/dev/null)"
if [ -z "$name" ]; then
  echo "FAIL: the grader could not create a TaskRun of the Task install-check in $NS."
  exit 1
fi
timeout="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.spec.timeout}')"
sa="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.spec.serviceAccountName}')"

status=""
for _ in $(seq 1 60); do
  status="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}' 2>/dev/null)"
  [ "$status" = "True" ] || [ "$status" = "False" ] && break
  sleep 3
done
kubectl -n "$NS" delete taskrun "$name" --wait=false >/dev/null 2>&1 || true

FAILED=0
if [ "$timeout" != "20m0s" ]; then
  echo "FAIL: a new TaskRun without a timeout got spec.timeout '${timeout}', expected 20m0s (default-timeout-minutes)."
  FAILED=1
fi
if [ "$sa" != "default" ]; then
  echo "FAIL: a new TaskRun without a ServiceAccount got serviceAccountName '${sa}', expected default (default-service-account)."
  FAILED=1
fi
if [ "$status" != "True" ]; then
  echo "FAIL: a new TaskRun of install-check did not succeed (Succeeded=${status:-none})."
  FAILED=1
fi
[ "$FAILED" -eq 0 ] || exit 1
echo "PASS: new TaskRuns get a 20m0s timeout and the ServiceAccount default, and succeed."
exit 0
