#!/usr/bin/env bash
# PASS when the two failed runs are gone, the two successful old runs are
# still there, and no failed run of deploy-check is left. Rejects
# `tkn taskrun delete --all` and `--task deploy-check` without --keep.
set -uo pipefail

NS="starfleet"
FAILED=0
for run in deploy-check-run-g5h6i deploy-check-run-j7k8l; do
  if kubectl -n "$NS" get taskrun "$run" >/dev/null 2>&1; then
    echo "FAIL: the failed TaskRun $run still exists."
    FAILED=1
  fi
done
for run in deploy-check-run-a1b2c deploy-check-run-d3e4f; do
  if ! kubectl -n "$NS" get taskrun "$run" >/dev/null 2>&1; then
    echo "FAIL: the successful TaskRun $run was deleted. Delete only the failed runs."
    FAILED=1
  fi
done
statuses="$(kubectl -n "$NS" get taskruns -l tekton.dev/task=deploy-check -o jsonpath='{range .items[*]}{.metadata.name}={.status.conditions[?(@.type=="Succeeded")].status}{"\n"}{end}' 2>/dev/null)"
failed_runs=""
while IFS= read -r line; do
  case "$line" in *=False) failed_runs="$failed_runs ${line%=False}" ;; esac
done <<< "$statuses"
if [ -n "$failed_runs" ]; then
  echo "FAIL: failed runs of deploy-check are left:$failed_runs"
  FAILED=1
fi
[ "$FAILED" -eq 0 ] || exit 1
echo "PASS: only the failed runs were deleted; the two successful old runs remain."
exit 0
