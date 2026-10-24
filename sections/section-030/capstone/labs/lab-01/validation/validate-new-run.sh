#!/usr/bin/env bash
# PASS when a new TaskRun started by tkn (deploy-check-run-...) ran
# deploy-check with crew=shuttle and deck=3, succeeded, and reports
# "Hello, shuttle on deck 3!".
set -uo pipefail

NS="starfleet"
EXPECTED="Hello, shuttle on deck 3!"

found=""
for name in $(kubectl -n "$NS" get taskruns -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
  case "$name" in
    deploy-check-run-a1b2c|deploy-check-run-d3e4f|deploy-check-run-g5h6i|deploy-check-run-j7k8l) continue ;;
    deploy-check-run-*) ;;
    *) continue ;;
  esac
  task_ref="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.spec.taskRef.name}')"
  crew="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.spec.params[?(@.name=="crew")].value}')"
  deck="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.spec.params[?(@.name=="deck")].value}')"
  status="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  greeting="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.results[?(@.name=="greeting")].value}')"
  if [ "$task_ref" = "deploy-check" ] && [ "$crew" = "shuttle" ] && [ "$deck" = "3" ] \
     && [ "$status" = "True" ] && [ "$greeting" = "$EXPECTED" ]; then
    found="$name"
    break
  fi
  echo "INFO: TaskRun $name has crew '${crew}', deck '${deck}', Succeeded=${status:-none}, greeting '${greeting}'."
done

if [ -z "$found" ]; then
  echo "FAIL: no new deploy-check-run-... TaskRun ran deploy-check with crew=shuttle and deck=3 and reported '$EXPECTED'."
  exit 1
fi
echo "PASS: TaskRun $found reports '$EXPECTED'."
exit 0
