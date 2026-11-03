# Overview: Run Pipelines With tkn (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Tekton Pipelines and the `tkn` command-line tool, and gives you an empty namespace for your own Pipelines. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Tekton Pipelines v1.17.1**, installed from its release manifest.
- The Tekton command-line tool `tkn`, version **0.46.2**, on your PATH.
- An empty namespace `starfleet` for your Pipelines and runs.
- The image `busybox:1.37.0`, already loaded on the node, for your steps.

## Helpers

Paste these once in each new terminal. `newest` prints the name of the newest PipelineRun of a Pipeline. `runs_of` lists the runs of a Pipeline with their status. `say_owner` shows who owns the TaskRuns of a run.

```sh
newest() {
  tkn pipelinerun list "$1" -n starfleet -o name --limit 1 | sed 's|.*/||'
}
runs_of() {
  tkn pipelinerun list "$1" -n starfleet
}
say_owner() {
  kubectl get taskruns -n starfleet -l tekton.dev/pipelineRun="$1" -o custom-columns=NAME:.metadata.name,OWNER:.metadata.ownerReferences[0].name
}
```

Use them like this: `newest deliver`, `runs_of deliver`, `say_owner $(newest deliver)`.

## Practice tasks

- Start a Pipeline with a required parameter and no `-p` flag, and read what `tkn` asks. Press Ctrl+C to leave.
- Start a Pipeline with `--dry-run --output yaml`, save the file, and create the run from it with `kubectl create -f`.
- Start `stamp` with a `volumeClaimTemplateFile` workspace and check that the PersistentVolumeClaim disappears when you delete the run.
- Use `tkn pipelinerun logs --last -t ship` on a Pipeline with three tasks, and compare it with the log of the whole run.
- Start `wait` twice, cancel one run with `tkn` and the other with `kubectl patch`, and compare their conditions.
- Write a plugin `tkn-last-failed` that prints the name of the newest failed run of a Pipeline.
- Run `tkn pipelinerun delete --all -f -n starfleet` and check what is left.
