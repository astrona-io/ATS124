# Overview: See How A Pipeline Becomes TaskRuns (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Tekton Pipelines and the `tkn` command-line tool, and gives you an empty namespace for your own Tasks and Pipelines. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Tekton Pipelines v1.17.1**, installed from its release manifest. The `tekton-pipelines-controller` in the namespace `tekton-pipelines` turns a `PipelineRun` into one `TaskRun` for each pipeline task, and one pod for each `TaskRun`.
- The Tekton command-line tool `tkn`, version **0.46.2**, on your PATH.
- An empty namespace `starfleet` for your Tasks, Pipelines and runs.
- The image `busybox:1.37.0`, already loaded on the node, for your steps.

A `Pipeline` is a definition and never runs by itself. A `PipelineRun` is one execution of a `Pipeline`. Every pipeline task has its own pod, so two pipeline tasks share files only through a workspace that is backed by a PersistentVolumeClaim.

## Helpers

Paste these once in each new terminal. `show_prs` lists the PipelineRuns with their `Succeeded` condition. `show_children` lists the TaskRuns that one PipelineRun created. `show_pr_results` prints the results of one PipelineRun.

```sh
show_prs() {
  kubectl get pipelineruns -n starfleet
}
show_children() {
  kubectl get taskruns -n starfleet -l tekton.dev/pipelineRun="$1" -L tekton.dev/pipelineTask
}
show_pr_results() {
  kubectl get pipelinerun "$1" -n starfleet -o jsonpath='{range .status.results[*]}{.name}{"="}{.value}{"\n"}{end}'
}
```

Use them like this: `show_prs`, `show_children launch-1`, `show_pr_results pass-data-1`.

## Practice tasks

- Write a `Pipeline` with three pipeline tasks where the third has `runAfter` on the first and the second. Run it and compare the start times of the three TaskRuns with `kubectl get taskruns -n starfleet -o custom-columns=NAME:.metadata.name,START:.status.startTime`.
- Run a Pipeline whose first pipeline task fails. Read `status.skippedTasks` of the PipelineRun and name the reason for each skipped task.
- Add `retries: 2` to a pipeline task whose step always fails, and read `status.retriesStatus` of its TaskRun.
- Add a `finally` task that prints `$(tasks.status)`, and run the Pipeline once with a passing and once with a failing task. What does the finally task print each time?
- Bind a workspace to `emptyDir` instead of a `volumeClaimTemplate`, run a Pipeline whose second task reads a file the first one wrote, and read the log of the failing task.
- Create a PipelineRun with `spec.timeouts.pipeline: 30s` for a Pipeline that sleeps for 120 seconds, and compare the reasons of the PipelineRun and its TaskRun.
- Delete a PipelineRun and check with `kubectl get taskruns,pods,pvc -n starfleet` which objects disappear with it.
