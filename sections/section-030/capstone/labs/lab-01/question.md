# Question

Solve this question on: `terminal`

**Time:** about 25 minutes · **Topic:** The tkn CLI

## Scenario

The namespace `starfleet` holds four old runs of the Task `deploy-check`, which checks that a crew member can be sent to a deck. Two of them failed, and the team lead wants a short triage before anyone runs the Task again. After the triage, the `shuttle` crew needs to go to deck 3.

## Your task

1. Find out, with `tkn`, which runs of `deploy-check` failed and in which step they failed.
2. Find out, with `tkn`, which version of Tekton Pipelines runs in the cluster.
3. Record both answers in a ConfigMap named `triage` in `starfleet`, with the keys `failed-step` (the name of the step, as the Task names it) and `pipelines-version` (the version exactly as `tkn` prints it, for example `v1.2.3`).
4. Delete the failed runs of `deploy-check`, and only those.
5. Start `deploy-check` with `tkn` for `crew` = `shuttle` and `deck` = `3`, and check its result.

## Constraints

- Keep the two old runs that succeeded.
- Start the new run with `tkn task start`, so that its name starts with `deploy-check-run-`.
- Do not change the Task `deploy-check`.

## Done when

- The ConfigMap `triage` in `starfleet` has `failed-step` and `pipelines-version` with the right values.
- No failed run of `deploy-check` is left in `starfleet`, and the two old runs that succeeded still exist.
- A new TaskRun whose name starts with `deploy-check-run-` ran `deploy-check` with `crew` = `shuttle` and `deck` = `3`, succeeded, and reports the result `greeting` = `Hello, shuttle on deck 3!`.
