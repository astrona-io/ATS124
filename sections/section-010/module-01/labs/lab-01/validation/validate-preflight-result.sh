#!/usr/bin/env bash
# PASS when the TaskRun preflight-run reports the result
# summary = "bridge: 3 checks passed".
set -uo pipefail

NS="starfleet"
TR="preflight-run"
EXPECTED="bridge: 3 checks passed"

summary="$(kubectl -n "$NS" get taskrun "$TR" -o jsonpath='{.status.results[?(@.name=="summary")].value}' 2>/dev/null)"
if [ "$summary" != "$EXPECTED" ]; then
  echo "FAIL: TaskRun $TR has the result summary='${summary}', expected '$EXPECTED'."
  exit 1
fi

echo "PASS: TaskRun $TR reports summary='$EXPECTED'."
exit 0
