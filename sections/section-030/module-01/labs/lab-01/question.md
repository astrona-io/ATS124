# Question

Solve this question on: `terminal`

**Time:** about 15 minutes · **Topic:** The tkn CLI

## Scenario

The `starfleet` team keeps its Tasks in the namespace `starfleet`. An old copy of the Task `hello` still lives in `default`, and someone already ran it there by mistake. The team now wants a proper greeting for the `bridge` crew, from the right Task, and no runs left in `default`.

## Your task

1. Use `tkn` to look at the Task `hello` in `starfleet`: its parameter and its result.
2. Start the Task `hello` in `starfleet` with `tkn task start`, with the parameter `crew` set to `bridge`. Follow its logs.
3. Read the result of the run.
4. Remove every TaskRun from the namespace `default`, including any you created by mistake.

## Constraints

- Start the run with `tkn task start`, so that its name starts with `hello-run-`. Do not write the TaskRun by hand.
- Do not delete or change either Task named `hello`.
- Do not change the Tasks' namespaces or create new Tasks.

## Done when

- A TaskRun in `starfleet` whose name starts with `hello-run-` ran the Task `hello` with `crew` = `bridge`, succeeded, and reports the result `greeting` = `Hello, bridge!`.
- The namespace `default` holds no TaskRun.
- Both Tasks named `hello`, in `starfleet` and in `default`, still exist.
