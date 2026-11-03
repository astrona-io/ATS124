# Follow The Tekton Controllers

Tekton is not one program. It is a set of Deployments that watch the Kubernetes API and react to changes. When a run fails, or never starts, you need to know which Deployment is responsible, what permissions it has, and where it writes its evidence. This module opens the `tekton-pipelines` namespace and follows a single run from the moment you apply it until the last event is written.

Keep one sentence in mind: **the webhook decides whether an object may be stored, the controller decides what happens to it, and both report what they did in the object's status, in events, in metrics and in their own logs.**

The module has four parts. **The Reconcile Loop And The Webhook** shows the two Deployments that do the work and what the webhook changes or rejects. **ServiceAccounts, RBAC And The Pod Template** shows who runs the pods and which permissions each side has. **Events, Conditions And Metrics** reads the signals a run leaves behind. **Where To Look First** turns the signals into a triage routine for a failed run. A graded lab follows the fourth part.

## Learning objectives

After this module you can:

- Name the Tekton Deployments, what each one does, and the webhook configurations they register.
- Explain what defaulting and validation change about an object before it is stored, and what happens when the webhook is down.
- Explain the reconcile loop in your own words: watch, queue, compare, act, write status.
- Run a `TaskRun` with a chosen ServiceAccount and pod template, and check the result on the pod.
- Check the permissions of the controller and of a step pod with `kubectl auth can-i`.
- Read Kubernetes events, conditions and the controller metrics endpoint for a run.
- Map a failed `TaskRun` to its reason (`TaskRunResolutionFailed`, `TaskRunValidationFailed`, `StepFailed`, `TaskRunTimeout`) and to the next command to run.

## Before you start

You need to know what a `Task`, a `TaskRun`, a `Pipeline` and a `PipelineRun` are, and how to read a `Succeeded` condition. You should be able to use `kubectl get`, `kubectl describe`, `kubectl logs` and `kubectl apply`.

Your playground is a single-node `kind` cluster with these parts:

| Part of the playground | What it is |
| --- | --- |
| Namespace `tekton-pipelines` | Tekton Pipelines v1.17.1: the controller, the webhook and the events controller |
| Namespace `tekton-pipelines-resolvers` | The remote resolvers |
| Namespace `starfleet` | Empty. Your Tasks, runs and ServiceAccounts go here |
| `tkn` on your PATH | The Tekton command-line tool, version 0.46.2 |

Every command runs against the playground cluster, and `kubectl` already points at it.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
