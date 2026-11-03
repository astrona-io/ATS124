# Summary

`tkn` has one set of commands for Pipelines and one for PipelineRuns. They create, read and change the same Kubernetes objects that `kubectl` does, and the controller in the cluster does the work.

## What you learned

`tkn pipeline list` and `tkn pipeline describe` show what a Pipeline expects: parameters with their defaults, workspaces and tasks. `tkn pipeline start` builds a `PipelineRun` with `-p` for parameters, `--workspace` for workspaces, `--prefix-name` for a readable name, `--showlog` to follow the logs and `--dry-run` to preview. A workspace backed by `emptyDir` lives in one pod, so tasks in different pods need a claim or a `volumeClaimTemplateFile`.

`tkn pipelinerun list`, `describe` and `logs` read the runs. `describe --last PIPELINE` picks the newest run of a Pipeline, and its Taskruns block shows which task failed. `logs -t TASK` reads one task and `-f` follows a running one. `tkn pipelinerun cancel` ends a run and keeps its record. `tkn pipeline start --use-pipelinerun NAME` creates a new run with the values of an old one. `tkn pipelinerun delete --pipeline NAME --keep N -f` keeps the newest runs and removes the rest, with their TaskRuns, pods and PVCs. In scripts, pass `-n`, give every parameter, use `-f` and parse `-o name` or `-o json`. An executable named `tkn-NAME` on the `PATH` becomes `tkn NAME`. The key facts to remember are these:

- `tkn pipeline` is for definitions and `tkn pipelinerun` is for executions.
- A script never relies on the current context or on a prompt.
- Cancel instead of delete when you want to keep the evidence.
- `--use-pipelinerun` copies values into a new run; it does not run the old one again.
- Name the Pipeline when you use `--last` or `--keep`.

<!-- astrona:playground:destroy -->
