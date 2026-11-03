# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Running Pipelines with tkn

## Scenario

The namespace `starfleet` holds the Pipeline `deliver`, which needs a parameter `target`, and five old runs of it. A run of the Pipeline `wait-forever` called `stuck` is blocking a pod and must be stopped. The team wants one new delivery to the target `orbit`, and wants only the newest runs of `deliver` kept.

## Your task

1. Start the Pipeline `deliver` with `tkn`, with the parameter `target` set to `orbit` and the run name starting with `ship`. Let it finish.
2. Stop the run `stuck`, but keep its record.
3. Delete the old runs of `deliver` so that only the three newest remain.

## Constraints

- Do not delete the PipelineRun `stuck`.
- Do not change the Pipelines.
- The new run must be created by `tkn pipeline start`, so it must not be an edited copy of an old run.

## Done when

- A PipelineRun whose name starts with `ship` has `Succeeded` = `True` and the result `summary` set to `orbit:v1`.
- The PipelineRun `stuck` still exists, with `spec.status` set to `Cancelled` and `Succeeded` = `False`.
- Exactly three PipelineRuns of `deliver` remain: the `ship` run, `deliver-old-4` and `deliver-old-5`.
