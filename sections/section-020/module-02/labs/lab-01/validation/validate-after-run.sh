#!/usr/bin/env bash
# PASS when the TaskRun "after" refers to the Task whoami, succeeded with the
# result uid=1000 and a pod labelled managed-by=starfleet-ci, and the TaskRun
# "before" still reports uid=0.
set -uo pipefail

NS="starfleet"

if ! kubectl -n "$NS" get taskrun after >/dev/null 2>&1; then
  echo "FAIL: TaskRun after does not exist in $NS."
  exit 1
fi
ref="$(kubectl -n "$NS" get taskrun after -o jsonpath='{.spec.taskRef.name}')"
if [ "$ref" != "whoami" ]; then
  echo "FAIL: TaskRun after must use taskRef name whoami (found '${ref:-an embedded taskSpec}')."
  exit 1
fi

status=""
for _ in $(seq 1 30); do
  status="$(kubectl -n "$NS" get taskrun after -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  if [ "$status" = "True" ] || [ "$status" = "False" ]; then break; fi
  sleep 3
done
if [ "$status" != "True" ]; then
  echo "FAIL: TaskRun after has Succeeded=${status:-none}."
  exit 1
fi

uid="$(kubectl -n "$NS" get taskrun after -o jsonpath='{.status.results[?(@.name=="uid")].value}')"
if [ "$uid" != "1000" ]; then
  echo "FAIL: TaskRun after reports uid='${uid}', expected 1000. It may have been created before the webhook saw the new defaults; delete it and create it again."
  exit 1
fi

pod="$(kubectl -n "$NS" get taskrun after -o jsonpath='{.status.podName}')"
managed="$(kubectl -n "$NS" get pod "$pod" -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}' 2>/dev/null)"
if [ "$managed" != "starfleet-ci" ]; then
  echo "FAIL: the pod of after has managed-by='${managed}', expected 'starfleet-ci'."
  exit 1
fi

before="$(kubectl -n "$NS" get taskrun before -o jsonpath='{.status.results[?(@.name=="uid")].value}' 2>/dev/null)"
if [ "$before" != "0" ]; then
  echo "FAIL: TaskRun before must still exist and report uid=0 (found '${before}')."
  exit 1
fi

echo "PASS: TaskRun after ran as user 1000 with the managed-by label starfleet-ci, and before still reports 0."
exit 0
