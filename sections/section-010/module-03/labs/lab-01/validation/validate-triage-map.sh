#!/usr/bin/env bash
# PASS when the ConfigMap triage has one key per failed TaskRun and every value
# equals the reason of that TaskRun's Succeeded condition.
set -uo pipefail

NS="starfleet"

if ! kubectl -n "$NS" get configmap triage >/dev/null 2>&1; then
  echo "FAIL: ConfigMap triage does not exist in $NS."
  exit 1
fi

for run in r-missing-task r-missing-param r-step-fail r-timeout; do
  actual="$(kubectl -n "$NS" get taskrun "$run" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].reason}' 2>/dev/null)"
  if [ -z "$actual" ]; then
    echo "FAIL: TaskRun $run has no reason in its Succeeded condition."
    exit 1
  fi
  recorded="$(kubectl -n "$NS" get configmap triage -o jsonpath="{.data.${run}}" 2>/dev/null)"
  if [ "$recorded" != "$actual" ]; then
    echo "FAIL: ConfigMap triage key $run is '${recorded}', but the TaskRun reason is '${actual}'."
    exit 1
  fi
done

echo "PASS: ConfigMap triage holds the reason of each of the four failed TaskRuns."
exit 0
