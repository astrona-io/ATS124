#!/usr/bin/env bash
# PASS when the namespace default holds no TaskRun, and both Tasks named hello
# (in starfleet and in default) still exist. Rejects deleting the decoy Task
# instead of cleaning up its runs.
set -uo pipefail

leftover="$(kubectl -n default get taskruns -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)"
if [ -n "$leftover" ]; then
  echo "FAIL: the namespace default still holds TaskRuns: $leftover"
  exit 1
fi
for ns in starfleet default; do
  if ! kubectl -n "$ns" get task hello >/dev/null 2>&1; then
    echo "FAIL: the Task hello in $ns is gone. Delete TaskRuns, not Tasks."
    exit 1
  fi
done
echo "PASS: no TaskRun is left in default, and both Tasks hello still exist."
exit 0
