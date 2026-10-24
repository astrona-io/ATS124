#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

BIN_DIR="/usr/local/bin"
[ -w "$BIN_DIR" ] || BIN_DIR="$HOME/.local/bin"
export PATH="$BIN_DIR:$PATH"

# 1. Start the Task hello in starfleet with crew=bridge and wait for it.
tkn task start hello -n starfleet -p crew=bridge --showlog

# 2. Remove every TaskRun from default (the Tasks stay).
tkn taskrun delete --all -n default -f

# 3. Make sure the run in starfleet has ended before the grader reads it.
for name in $(kubectl -n starfleet get taskruns -l tekton.dev/task=hello -o jsonpath='{.items[*].metadata.name}'); do
  kubectl -n starfleet wait --for=condition=Succeeded "taskrun/$name" --timeout=180s
done
