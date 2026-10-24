# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** The execution model

## Scenario

Before every launch, the `starfleet` team runs the Task `preflight`. It has two steps: `collect` writes one line per system check to a file, and `verify` counts the lines and reports the count as the result `summary`. Today the TaskRun `preflight-run` for the `bridge` crew failed, and nobody on the team knows how to read a failed TaskRun.

## Your task

1. Find out why the TaskRun `preflight-run` in the namespace `starfleet` failed. Read its `Succeeded` condition first, then its pod and step logs if there is a pod.
2. Fix every fault you find, in the `TaskRun` and in the `Task`. There is more than one.
3. Leave a TaskRun named `preflight-run` that succeeds and reports the result `summary` as `bridge: 3 checks passed`.

## Constraints

- Keep the name `preflight-run`. The TaskRun must refer to the Task `preflight` with `taskRef`; do not embed the steps with `taskSpec`.
- Keep the two steps `collect` and `verify`, in that order, with the image `busybox:1.37.0`. Do not merge them into one step.
- `verify` must count the lines that `collect` wrote. Do not type the number into the script: the grader runs the Task again with four checks of its own and expects `4`.
- Do not change the parameters or results of the Task.

## Done when

- The TaskRun `preflight-run` in `starfleet` uses the Task `preflight`, passes `target` = `bridge`, ran `collect` and then `verify`, and its `Succeeded` condition is `True`.
- Its result `summary` is `bridge: 3 checks passed`.
- A new TaskRun of `preflight` with `target` = `probe` and `checks` = `alpha beta gamma delta` succeeds with `summary` = `probe: 4 checks passed`.
