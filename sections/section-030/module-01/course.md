# Run And Inspect Work With tkn

You want to run a Task once with a different value, see its output while it runs, and then find out why yesterday's run failed. With `kubectl` that is three YAML files and three long commands. With the Tekton command-line tool it is three short commands. This module teaches those commands, and the one rule that decides where they run.

`tkn` is the command-line tool of Tekton. It is a client of the Kubernetes API server, like `kubectl`: it reads your kubeconfig file, sends requests to the cluster, and creates or reads Tekton objects. It never talks to the Tekton controller directly. `tkn task start` creates a `TaskRun`, and the controller in the cluster runs it.

Keep one sentence in mind: **`tkn` works in the cluster and namespace of your current kubeconfig context unless you say otherwise.** The flags `--context` and `-n` say otherwise. A Task with the same name can exist in two namespaces, and `tkn` happily starts the wrong one.

The module has three parts. **Set Up tkn And Choose The Cluster And Namespace** installs `tkn`, checks it with `tkn version`, and shows how kubeconfig contexts and namespaces decide where it works. **Start Tasks With tkn** lists and describes Tasks and starts them with parameters, following their logs. **Inspect And Clean Up TaskRuns** lists, describes and reads TaskRuns, and deletes the ones you no longer need. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Install `tkn` 0.46.2 on macOS or Linux and check the client and cluster versions with `tkn version`.
- Explain how `tkn` chooses the cluster and the namespace, and use `--context`, `--kubeconfig` and `-n`.
- Create a kubeconfig context with a default namespace, and switch between contexts.
- Start a Task with `tkn task start`, pass parameters with `-p`, and follow the logs with `--showlog`.
- Read the status, parameters and results of a TaskRun with `tkn taskrun describe`, and its logs with `tkn taskrun logs`.
- Delete TaskRuns with `tkn taskrun delete`, by name, by Task, or keeping the newest ones.

## Before you start

You need Kubernetes basics: namespaces, the kubeconfig file, and the commands `kubectl get` and `kubectl config`. You should know what a `Task` and a `TaskRun` are: a `Task` is a list of steps with parameters and results, and a `TaskRun` is one execution of it, which Tekton runs as one pod with one container per step.

Your playground is a single-node `kind` cluster with these parts:

| Part of the playground | What it is |
| --- | --- |
| Namespace `tekton-pipelines` | Tekton Pipelines v1.17.1 and the read-only Tekton Dashboard v0.73.0 |
| Namespace `tekton-pipelines-resolvers` | The remote resolvers of Tekton Pipelines |
| Namespace `starfleet` | Empty. Your Tasks and TaskRuns go here |
| `tkn` on your PATH | The Tekton command-line tool, version 0.46.2 |

Every command in the parts runs against the playground cluster, and `kubectl` and `tkn` already point at it.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
