#!/usr/bin/env bash
# PASS when the four Tekton Pipelines Deployments are Available and the
# installed version is still v1.17.1.
set -uo pipefail

FAILED=0
check_available() {
  # check_available NAMESPACE DEPLOYMENT
  local available
  available="$(kubectl -n "$1" get deployment "$2" -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' 2>/dev/null)"
  if [ "$available" != "True" ]; then
    echo "FAIL: Deployment $2 in $1 is not Available."
    FAILED=1
  fi
}
check_available tekton-pipelines tekton-pipelines-controller
check_available tekton-pipelines tekton-pipelines-webhook
check_available tekton-pipelines tekton-events-controller
check_available tekton-pipelines-resolvers tekton-pipelines-remote-resolvers

version="$(kubectl -n tekton-pipelines get configmap pipelines-info -o jsonpath='{.data.version}' 2>/dev/null)"
if [ "$version" != "v1.17.1" ]; then
  echo "FAIL: pipelines-info reports version '${version}', expected v1.17.1."
  FAILED=1
fi

[ "$FAILED" -eq 0 ] || exit 1
echo "PASS: Tekton Pipelines v1.17.1 runs with all four Deployments Available."
exit 0
