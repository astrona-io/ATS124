#!/usr/bin/env bash
# PASS when starfleet holds a TaskRun started by `tkn task start hello`
# (name hello-run-...), referring to the Task hello, with crew=bridge, that
# succeeded and reports greeting "Hello, bridge!".
set -uo pipefail

NS="starfleet"
EXPECTED="Hello, bridge!"

names="$(kubectl -n "$NS" get taskruns -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)"
if [ -z "$names" ]; then
  echo "FAIL: there is no TaskRun in $NS. Start the Task hello there with tkn."
  exit 1
fi

found=""
for name in $names; do
  case "$name" in hello-run-*) ;; *) continue ;; esac
  task_ref="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.spec.taskRef.name}')"
  crew="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.spec.params[?(@.name=="crew")].value}')"
  status="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')"
  greeting="$(kubectl -n "$NS" get taskrun "$name" -o jsonpath='{.status.results[?(@.name=="greeting")].value}')"
  if [ "$task_ref" = "hello" ] && [ "$crew" = "bridge" ] && [ "$status" = "True" ] && [ "$greeting" = "$EXPECTED" ]; then
    found="$name"
    break
  fi
  echo "INFO: TaskRun $name has taskRef '${task_ref}', crew '${crew}', Succeeded=${status:-none}, greeting '${greeting}'."
done

if [ -z "$found" ]; then
  echo "FAIL: no TaskRun hello-run-... in $NS ran the Task hello with crew=bridge and reported '$EXPECTED'."
  exit 1
fi
echo "PASS: TaskRun $found in $NS ran hello with crew=bridge and reports '$EXPECTED'."
exit 0
