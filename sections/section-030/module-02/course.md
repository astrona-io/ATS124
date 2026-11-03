# Run Pipelines With tkn

A `Pipeline` is started, watched, stopped and cleaned up many times a day. With `kubectl` each of those needs a YAML file or a long jsonpath. The Tekton command-line tool has a short command for each, and it reads the same objects that `kubectl` reads. This module teaches the pipeline side of `tkn`: starting a `Pipeline` with parameters and workspaces, reading a `PipelineRun` and its logs, cancelling one, running it again, and removing the runs you no longer need.

`tkn pipeline start` does what you did by hand in the pipeline module: it creates a `PipelineRun` that refers to the Pipeline. The tekton-pipelines-controller does the rest. `tkn` never runs anything itself.

Keep one sentence in mind: **`tkn pipeline` works on definitions, `tkn pipelinerun` works on executions, and both choose the cluster and the namespace from your kubeconfig unless you say `--context` or `-n`.**

The module has four parts. **List, Describe And Start Pipelines** reads Pipelines and starts them with parameters and workspaces. **Read PipelineRuns And Their Logs** lists, describes and follows the runs. **Cancel, Rerun And Clean Up** stops a run, starts it again with the same values and removes old runs. **Plugins And Scripts** extends `tkn` with your own command and uses it in a script. A graded lab follows the third part.

## Learning objectives

After this module you can:

- List and describe Pipelines with `tkn pipeline list` and `tkn pipeline describe`.
- Start a Pipeline with `-p` for parameters, `--workspace` for workspaces, `--prefix-name` and `--showlog`.
- Preview a `PipelineRun` with `--dry-run` before it is created.
- Read a `PipelineRun`, its results and its TaskRuns with `tkn pipelinerun describe`.
- Follow logs of a whole run or of one task with `tkn pipelinerun logs`.
- Cancel a run with `tkn pipelinerun cancel`, and start the same Pipeline again with `--use-pipelinerun`.
- Delete old runs by Pipeline and by count with `tkn pipelinerun delete`.
- Add a `tkn` plugin and use `tkn` in a shell script.

## Before you start

You need to know what a `Pipeline` and a `PipelineRun` are, what a workspace is, and the basic `tkn task` commands: start, describe, logs and delete. You should be able to read a `Succeeded` condition.

Your playground is a single-node `kind` cluster with these parts:

| Part of the playground | What it is |
| --- | --- |
| Namespace `tekton-pipelines` | Tekton Pipelines v1.17.1 |
| Namespace `starfleet` | Empty. Your Tasks, Pipelines and runs go here |
| `tkn` on your PATH | The Tekton command-line tool, version 0.46.2 |

Every command runs against the playground cluster, and `kubectl` already points at it.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
