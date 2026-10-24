# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** The execution model

## Scenario

The `starfleet` team wrote the Task `inspect` to check the areas of one crew member. It has three steps: `scan` writes one line per area to a file, `summarize` counts the lines, and `report` turns the count into the result `report`. The TaskRun `inspect-run` for `scout` has never worked. The team says the run must use the ServiceAccount `inspector`, because later versions of the Task will need its permissions.

## Your task

1. Find out why `inspect-run` in the namespace `starfleet` fails. Each time you fix one fault, run it again and read the next failure.
2. Fix every fault. There are three, and they sit in different places: the Task, the namespace and the TaskRun's environment.
3. Leave a TaskRun named `inspect-run` that succeeds and reports `scout: 3 findings, status green`.

## Constraints

- The Task `inspect` must live in `starfleet` and keep its three steps `scan`, `summarize` and `report`. Fix the order of the steps; do not change what each step does.
- The TaskRun `inspect-run` must keep `serviceAccountName: inspector`, `taskRef` name `inspect` and the parameter `target` = `scout`. Do not embed the steps with `taskSpec`.
- Do not change the ConfigMaps in `tekton-pipelines`.

## Done when

- The Task `inspect` exists in `starfleet` with the steps `scan`, `summarize`, `report`, in that order.
- The ServiceAccount `inspector` exists in `starfleet`, and the pod of `inspect-run` ran as it.
- `inspect-run` succeeded, its pod has the containers `step-scan`, `step-summarize`, `step-report`, and its result `report` is `scout: 3 findings, status green`.
