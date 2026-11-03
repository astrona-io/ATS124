#!/usr/bin/env bash
# PASS when the PipelineRun roster-run reports the result
# report = "roster has 3 names, first: bridge".
set -uo pipefail

NS="starfleet"
PR="roster-run"
EXPECTED="roster has 3 names, first: bridge"

report="$(kubectl -n "$NS" get pipelinerun "$PR" -o jsonpath='{.status.results[?(@.name=="report")].value}' 2>/dev/null)"
if [ "$report" != "$EXPECTED" ]; then
  echo "FAIL: PipelineRun $PR has the result report='${report}', expected '$EXPECTED'."
  exit 1
fi

echo "PASS: PipelineRun $PR reports report='$EXPECTED'."
exit 0
