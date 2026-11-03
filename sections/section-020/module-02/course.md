# Operate The Tekton Installation

Installing Tekton is a one-time job. Operating it is the work that comes after: seeing what the controller is doing, keeping it available when a node fails, stopping one team from using the whole cluster, and deciding who owns the configuration. This module covers the settings and objects an administrator touches after the first TaskRun succeeded.

Almost all of that work happens in ConfigMaps in the namespace `tekton-pipelines`. Each Deployment watches its own ConfigMaps, so a change takes effect within seconds and without a restart. The ConfigMaps belong to different jobs: `config-logging` and `config-observability` decide what the controller reports, the `config-leader-election-*` ConfigMaps decide how several replicas share the work, and `config-defaults` decides what every new run gets.

Keep one sentence in mind: **an administrator changes a ConfigMap, the Deployment that watches it applies the change, and the effect is visible in the next run, log line or lease.**

The module has four parts. **Logging And Observability** changes the log level and reads the observability settings. **High Availability And Leader Election** runs more than one replica and reads the lease objects. **Limit What Runs Can Use** sets a default pod template, a managed-by label and a ResourceQuota. **The Tekton Operator And TektonConfig** shows how the same settings are managed when an operator owns the installation. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Change the log level of the controller through `config-logging`, and say what the change affects.
- Read the keys of `config-observability` and explain which ones decide what the metrics endpoint exposes.
- Explain leader election and list the Lease objects that Tekton uses.
- Run the controller with more than one replica and set the `buckets` value to match.
- Set `default-pod-template` and `default-managed-by-label-value` in `config-defaults`, and check their effect on a new pod.
- Limit a namespace with a ResourceQuota and describe how Tekton computes the requests of a pod.
- Explain what the Tekton Operator and the `TektonConfig` resource change about who owns a setting.

## Before you start

You need to know how Tekton Pipelines is installed from its release manifest, and what `config-defaults` is. You should be able to use `kubectl get`, `kubectl patch`, `kubectl edit`, `kubectl logs` and `kubectl rollout status`.

Your playground is a single-node `kind` cluster with these parts:

| Part of the playground | What it is |
| --- | --- |
| Namespace `tekton-pipelines` | Tekton Pipelines v1.17.1: the controller, the webhook and the events controller |
| Namespace `tekton-pipelines-resolvers` | The remote resolvers |
| Namespace `starfleet` | Empty. Your Tasks and runs go here |
| `tkn` on your PATH | The Tekton command-line tool, version 0.46.2 |

Every command runs against the playground cluster, and `kubectl` already points at it.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
