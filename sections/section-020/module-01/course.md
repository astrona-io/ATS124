# Install And Configure Tekton

A colleague says "Tekton is installed" on a new cluster. How do you check that it really works, which version it is, and what every TaskRun will get by default? This module answers those questions by installing Tekton yourself, step by step, on an empty cluster.

Tekton Pipelines installs from one YAML file, the release manifest. `kubectl apply` creates everything in it: two namespaces, the custom resource definitions (CRDs), the controller and the webhook, the role-based access control (RBAC) rules and a set of ConfigMaps. Two of those ConfigMaps decide how every run behaves: `config-defaults` holds default values, and `feature-flags` switches features on and off. The Tekton Dashboard, a web interface, installs from a second release manifest.

Keep one sentence in mind: **an installation is proved by a TaskRun that succeeds, not by pods that are running.** Running pods show that the containers started. Only a TaskRun shows that the webhook accepts objects, the controller creates pods, and the steps can run.

The module has three parts. **Install Tekton Pipelines From The Release Manifest** applies the release, walks through what it created, and proves it with a first TaskRun. **Configure Defaults And Feature Flags** changes the default timeout and ServiceAccount, and shows when such a change takes effect. **Install The Tekton Dashboard** installs the read-only Dashboard, opens it in a browser, and compares it with the read/write release. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Install Tekton Pipelines v1.17.1 from its release manifest and say which Kubernetes version it needs.
- List what the release creates in `tekton-pipelines` and `tekton-pipelines-resolvers`, and say what each Deployment does.
- Verify an installation with `kubectl rollout status`, the ConfigMap `pipelines-info`, `tkn version` and a TaskRun.
- Change `default-timeout-minutes` and `default-service-account` in `config-defaults`, and explain why old TaskRuns keep their old values.
- Read the main switches in `feature-flags`.
- Install the Tekton Dashboard v0.73.0 in read-only mode, open it on port `9097`, and explain what the read/write release adds.

## Before you start

You need Kubernetes basics: namespaces, Deployments, ConfigMaps, ServiceAccounts, ClusterRoleBindings, and the commands `kubectl apply`, `kubectl get`, `kubectl patch`, `kubectl rollout status` and `kubectl port-forward`. You should know what a `Task` and a `TaskRun` are: a `Task` is a list of steps, and a `TaskRun` is one execution of it, which Tekton runs as one pod.

Your playground is a single-node `kind` cluster with these parts:

| Part of the playground | What it is |
| --- | --- |
| Namespace `starfleet` | Empty. Your Tasks and TaskRuns go here |
| `tkn` on your PATH | The Tekton command-line tool, version 0.46.2 |
| Image `busybox:1.37.0` | Already loaded on the node, for your steps |

Tekton is **not** installed. The parts install it. The playground needs outbound internet, because the release manifests and Tekton's own images come from the internet.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
