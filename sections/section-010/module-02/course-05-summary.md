# Summary

A `Pipeline` groups Tasks into a graph, and a `PipelineRun` runs it. Tekton does this without a new kind of pod: it creates ordinary `TaskRuns`, and each one keeps its own pod, step containers and logs.

## What you learned

A `Pipeline` lists pipeline tasks, and each one points at a `Task`. Tasks without a relation run at the same time. `runAfter` and references to another task's result make a task wait. The tekton-pipelines-controller creates a `TaskRun` named after the run and the pipeline task when a task is allowed to start, and it never creates a `TaskRun` for a task that is skipped.

Every child `TaskRun` has an owner reference to the `PipelineRun` and the labels `tekton.dev/pipeline`, `tekton.dev/pipelineRun` and `tekton.dev/pipelineTask`. The `PipelineRun` lists its children in `status.childReferences` and keeps a copy of the Pipeline in `status.pipelineSpec`. Deleting the `PipelineRun` deletes its TaskRuns, their pods and the PVC that a `volumeClaimTemplate` created.

Each Task runs in its own pod, so `/workspace` and `/tmp` do not carry files from one Task to the next. A short value travels as a result, read with `$(tasks.<task>.results.<name>)`. A file travels in a workspace that the `PipelineRun` binds to a PVC. A failed task skips the tasks that depend on it. `retries` runs the same `TaskRun` again, and `finally` tasks run last, whatever happened. A `PipelineRun` ends early with `spec.timeouts` or with `spec.status: Cancelled`. The key facts to remember are these:

- A `PipelineRun` is a group of `TaskRuns`; only the `TaskRuns` have pods.
- Find the failed Task through `status.childReferences` or the label `tekton.dev/pipelineRun`.
- Results carry short values; workspaces carry files.
- A required workspace that the run does not bind makes the run fail before any pod starts.
- Retries keep earlier attempts in `status.retriesStatus` of the same `TaskRun`.

<!-- astrona:playground:destroy -->
