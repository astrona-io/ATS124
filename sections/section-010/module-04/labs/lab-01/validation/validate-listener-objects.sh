#!/usr/bin/env bash
# PASS when trigger-sa, target-binding, deliver-template and deliver-listener
# exist in starfleet, the listener runs as trigger-sa, and the template creates
# a PipelineRun.
set -uo pipefail

NS="starfleet"

for pair in serviceaccount/trigger-sa triggerbinding/target-binding triggertemplate/deliver-template eventlistener/deliver-listener; do
  if ! kubectl -n "$NS" get "$pair" >/dev/null 2>&1; then
    echo "FAIL: $pair does not exist in $NS."
    exit 1
  fi
done

sa="$(kubectl -n "$NS" get eventlistener deliver-listener -o jsonpath='{.spec.serviceAccountName}')"
if [ "$sa" != "trigger-sa" ]; then
  echo "FAIL: the listener runs as '${sa}', expected trigger-sa."
  exit 1
fi

kind="$(kubectl -n "$NS" get triggertemplate deliver-template -o jsonpath='{.spec.resourcetemplates[0].kind}')"
if [ "$kind" != "PipelineRun" ]; then
  echo "FAIL: the template creates '${kind}', expected PipelineRun."
  exit 1
fi

echo "PASS: the account, binding, template and listener exist and fit together."
exit 0
