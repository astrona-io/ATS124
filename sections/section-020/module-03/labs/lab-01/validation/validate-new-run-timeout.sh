#!/usr/bin/env bash
# PASS when a new TaskRun in starfleet succeeds and gets a 30 minute timeout.
set -uo pipefail

NS="starfleet"

run=""
for _ in $(seq 1 30); do
  run="$(cat <<EOF | kubectl create -f - -o name 2>/dev/null
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: grader-
  namespace: $NS
  labels:
    astrona.io/grader: "true"
spec:
  taskSpec:
    steps:
      - name: say
        image: busybox:1.37.0
        script: |
          #!/bin/sh
          echo grader
EOF
)"
  [ -n "$run" ] && break
  sleep 10
done
if [ -z "$run" ]; then
  echo "FAIL: the grader could not create a TaskRun. Is Tekton Pipelines installed?"
  exit 1
fi

status=""
for _ in $(seq 1 60); do
  status="$(kubectl -n "$NS" get "$run" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  if [ "$status" = "True" ] || [ "$status" = "False" ]; then break; fi
  sleep 3
done
if [ "$status" != "True" ]; then
  echo "FAIL: the grader's TaskRun has Succeeded=${status:-none}."
  exit 1
fi

timeout="$(kubectl -n "$NS" get "$run" -o jsonpath='{.spec.timeout}')"
case "$timeout" in
  30m0s|0h30m0s) ;;
  *) echo "FAIL: the new TaskRun has timeout '${timeout}', expected 30 minutes."; exit 1 ;;
esac

echo "PASS: a new TaskRun succeeded with a 30 minute timeout."
exit 0
