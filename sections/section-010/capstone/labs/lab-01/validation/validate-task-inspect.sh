#!/usr/bin/env bash
# PASS when the Task inspect exists in starfleet with the steps
# scan, summarize, report in that order.
set -uo pipefail

steps="$(kubectl -n starfleet get task inspect -o jsonpath='{.spec.steps[*].name}' 2>/dev/null)"
if [ -z "$steps" ]; then
  echo "FAIL: the Task inspect does not exist in the namespace starfleet."
  exit 1
fi
if [ "$steps" != "scan summarize report" ]; then
  echo "FAIL: the Task inspect in starfleet must run 'scan summarize report' in that order (found '$steps')."
  exit 1
fi
echo "PASS: the Task inspect is in starfleet with the steps scan, summarize, report."
exit 0
