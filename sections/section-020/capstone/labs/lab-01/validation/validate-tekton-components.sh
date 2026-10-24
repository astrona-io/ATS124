#!/usr/bin/env bash
# PASS when the four Tekton Pipelines Deployments run at least one ready
# replica each, and the webhook admits a new Task (server-side dry run).
set -uo pipefail

FAILED=0
check_ready() {
  # check_ready NAMESPACE DEPLOYMENT
  local ready
  ready="$(kubectl -n "$1" get deployment "$2" -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
  if [ -z "$ready" ] || [ "$ready" -lt 1 ]; then
    echo "FAIL: Deployment $2 in $1 has no ready replica."
    FAILED=1
  fi
}
check_ready tekton-pipelines tekton-pipelines-controller
check_ready tekton-pipelines tekton-pipelines-webhook
check_ready tekton-pipelines tekton-events-controller
check_ready tekton-pipelines-resolvers tekton-pipelines-remote-resolvers

probe="$(mktemp)"
trap 'rm -f "$probe"' EXIT
cat > "$probe" <<'YAML'
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: grader-probe
  namespace: starfleet
spec:
  steps:
    - name: probe
      image: busybox:1.37.0
      script: |
        echo probe
YAML
if ! out="$(kubectl apply --dry-run=server -f "$probe" 2>&1)"; then
  echo "FAIL: the API server refuses a Tekton Task: $out"
  FAILED=1
fi

[ "$FAILED" -eq 0 ] || exit 1
echo "PASS: the controller, webhook, events controller and resolvers are ready, and the webhook admits Tasks."
exit 0
