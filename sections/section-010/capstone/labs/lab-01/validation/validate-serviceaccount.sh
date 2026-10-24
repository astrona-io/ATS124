#!/usr/bin/env bash
# PASS when the ServiceAccount inspector exists in starfleet, the TaskRun
# inspect-run asks for it, and the pod of inspect-run really ran as it.
# Rejects the shortcut of dropping serviceAccountName from the TaskRun.
set -uo pipefail

NS="starfleet"

if ! kubectl -n "$NS" get serviceaccount inspector >/dev/null 2>&1; then
  echo "FAIL: the ServiceAccount inspector does not exist in $NS."
  exit 1
fi
sa="$(kubectl -n "$NS" get taskrun inspect-run -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)"
if [ "$sa" != "inspector" ]; then
  echo "FAIL: the TaskRun inspect-run must set serviceAccountName: inspector (found '${sa}')."
  exit 1
fi
pod="$(kubectl -n "$NS" get taskrun inspect-run -o jsonpath='{.status.podName}' 2>/dev/null)"
pod_sa="$(kubectl -n "$NS" get pod "${pod:-none}" -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)"
if [ "$pod_sa" != "inspector" ]; then
  echo "FAIL: the pod of inspect-run ('${pod}') did not run as the ServiceAccount inspector (found '${pod_sa}')."
  exit 1
fi
echo "PASS: the pod $pod of inspect-run ran as the ServiceAccount inspector."
exit 0
