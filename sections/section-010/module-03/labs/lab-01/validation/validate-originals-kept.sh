#!/usr/bin/env bash
# PASS when the four failed TaskRuns still exist with Succeeded=False and their
# original task references, and the three Tasks still exist.
set -uo pipefail

NS="starfleet"

check() {
  # check RUN TASKREF
  local status ref
  status="$(kubectl -n "$NS" get taskrun "$1" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}' 2>/dev/null)"
  ref="$(kubectl -n "$NS" get taskrun "$1" -o jsonpath='{.spec.taskRef.name}' 2>/dev/null)"
  if [ "$status" != "False" ]; then
    echo "FAIL: TaskRun $1 must still exist with Succeeded=False (found '${status:-missing}')."
    exit 1
  fi
  if [ "$ref" != "$2" ]; then
    echo "FAIL: TaskRun $1 must still refer to the Task '$2' (found '${ref}')."
    exit 1
  fi
}

check r-missing-task ghost-task
check r-missing-param echo-name
check r-step-fail fail-fast
check r-timeout sleeper

for task in echo-name fail-fast sleeper; do
  if ! kubectl -n "$NS" get task "$task" >/dev/null 2>&1; then
    echo "FAIL: Task $task is missing."
    exit 1
  fi
done

echo "PASS: the four failed TaskRuns and the three Tasks are unchanged."
exit 0
