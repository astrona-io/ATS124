#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the lab stays unsolved for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

# 1. Deliver once with tkn.
tkn pipeline start deliver -n starfleet -p target=orbit --use-param-defaults --prefix-name ship
SHIP="$(tkn pipelinerun list deliver -n starfleet -o name | grep '/ship-' | sed 's|.*/||' | head -n 1)"
kubectl -n starfleet wait --for=condition=Succeeded "pipelinerun/$SHIP" --timeout=300s

# 2. Cancel the hung run and keep its record.
tkn pipelinerun cancel stuck -n starfleet

# 3. Keep the newest three runs of deliver.
tkn pipelinerun delete --pipeline deliver --keep 3 -n starfleet -f
