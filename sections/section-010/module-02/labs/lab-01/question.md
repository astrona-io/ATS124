# Question

Solve this question on: `terminal`

**Time:** about 25 minutes · **Topic:** Pipelines and PipelineRuns

## Scenario

The `starfleet` team keeps a crew roster with a Pipeline called `roster`. The pipeline task `write` writes one line per crew name into a shared folder and reports how many names it wrote. The pipeline task `read` reads the roster and reports a one-line summary as the Pipeline result `report`. The PipelineRun `roster-run` for the crew `bridge scout probe` failed, and nobody on the team knows why.

## Your task

1. Find out why the PipelineRun `roster-run` in the namespace `starfleet` failed. Read its `Succeeded` condition first.
2. Fix every fault you find, in the `Pipeline` and in the `PipelineRun`. There is more than one.
3. Leave a PipelineRun named `roster-run` that succeeds and reports the result `report` as `roster has 3 names, first: bridge`.

## Constraints

- Keep the name `roster-run`. It must refer to the Pipeline `roster` with `pipelineRef`; do not embed the Pipeline with `pipelineSpec`.
- Keep the two pipeline tasks `write` and `read`, and keep them referring to the Tasks with `taskRef`. Do not change the Tasks.
- The two pipeline tasks must share the roster through a workspace backed by a PersistentVolumeClaim created from a `volumeClaimTemplate`. Do not use an `emptyDir`.
- The count must come from the result of `write`. Do not type the number into the Pipeline.

## Done when

- The PipelineRun `roster-run` uses the Pipeline `roster`, passes `crew` = `bridge scout probe`, has TaskRuns for `write` and `read`, and its `Succeeded` condition is `True`.
- Its result `report` is `roster has 3 names, first: bridge`.
- A new PipelineRun of `roster` with `crew` = `alpha beta` and its own `volumeClaimTemplate` succeeds with `report` = `roster has 2 names, first: alpha`.
