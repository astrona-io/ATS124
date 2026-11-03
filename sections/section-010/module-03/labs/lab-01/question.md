# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Controllers and failure triage

## Scenario

Four `TaskRuns` in the namespace `starfleet` failed during the night: `r-missing-task`, `r-missing-param`, `r-step-fail` and `r-timeout`. The on-call engineer wants a record of why each one failed, and a run that shows the work can be done.

## Your task

1. Read the `Succeeded` condition of each of the four `TaskRuns` and find the reason of each failure.
2. Create a ConfigMap named `triage` in the namespace `starfleet`. It has one key for each failed `TaskRun`, named exactly like the run, and the value is the reason from its `Succeeded` condition.
3. Create a new `TaskRun` named `r-fixed` that uses the Task `echo-name` with the parameter `name` set to `warp`, and make sure it succeeds.

## Constraints

- Do not delete, edit or recreate the four failed `TaskRuns`, and do not change the Tasks.
- Copy the reason from the cluster. The grader compares your values with the reasons that the `TaskRuns` carry.
- `r-fixed` must refer to the Task with `taskRef`.

## Done when

- The ConfigMap `triage` has the four keys `r-missing-task`, `r-missing-param`, `r-step-fail` and `r-timeout`, and each value equals the reason of that `TaskRun`.
- The four original `TaskRuns` still exist and still have `Succeeded` = `False`.
- The `TaskRun` `r-fixed` has `Succeeded` = `True` and its result `greeting` is `hello warp`.
