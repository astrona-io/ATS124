# See How Tekton Runs A Task

A build fails in your CI/CD system, and the only thing you see is a red mark. Was the problem in the build script, in the container image, in a missing permission, or in the CI/CD system itself? With Tekton you can answer that question with plain Kubernetes tools, because every part of a Tekton run is a Kubernetes object or a pod. This module shows you those objects and that pod.

Tekton Pipelines adds new resource kinds to the Kubernetes API. A `Task` is a list of steps, and a `TaskRun` is one execution of a `Task`. A controller in the cluster, tekton-pipelines-controller, watches TaskRuns and creates one pod for each of them. Each step of the `Task` becomes one container in that pod.

Keep one sentence in mind: **a `TaskRun` is a pod, and a step is a container.** Everything you know about pods (logs, events, container status, volumes) applies to Tekton. What Tekton adds is the order of the steps and the status it writes back to the `TaskRun`.

The module has three parts. **What Tekton Is And The Tekton Ecosystem** explains where Tekton comes from, lists the custom resources and the components Tekton Pipelines installs, and names the other Tekton projects. **One Pod Per TaskRun, One Container Per Step** runs a hello-world Task and opens up its pod: the containers, the entrypoint binary that puts the steps in order, and the folders the steps share. **Parameters, Results And The Status Of A TaskRun** passes values in, reads values out, and shows how to read a failed TaskRun. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Explain what Tekton is and where it sits: an incubating project of the Cloud Native Computing Foundation (CNCF), built on Kubernetes custom resources.
- Name the custom resources of Tekton Pipelines and say what each one is for.
- Name the components in the namespaces `tekton-pipelines` and `tekton-pipelines-resolvers`, and say which one does what.
- Name the projects of the Tekton ecosystem: Triggers, the `tkn` command-line tool, the Dashboard, the Catalog and Artifact Hub, Chains, the Operator, Pipelines-as-Code, Results and the Pruner.
- Find the pod of a `TaskRun`, its step containers and its init containers.
- Explain how the entrypoint binary runs steps in order, and which folders steps share.
- Pass parameters, read results, and read the `Succeeded` condition of a `TaskRun`.

## Before you start

You need Kubernetes basics: namespaces, pods, containers, ServiceAccounts, and the commands `kubectl get`, `kubectl apply`, `kubectl describe` and `kubectl logs`. You do not need to know Tekton or any other CI/CD system.

Your playground is a single-node `kind` cluster with these parts:

| Part of the playground | What it is |
| --- | --- |
| Namespace `tekton-pipelines` | Tekton Pipelines v1.17.1: the controller, the webhook and the events controller |
| Namespace `tekton-pipelines-resolvers` | The remote resolvers, which fetch Tasks from outside the cluster |
| Namespace `starfleet` | Empty. Your Tasks and TaskRuns go here |
| `tkn` on your PATH | The Tekton command-line tool, version 0.46.2 |

Every command in the parts runs against the playground cluster, and `kubectl` already points at it.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
