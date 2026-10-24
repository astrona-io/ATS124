# Summary

A Tekton installation is a set of Kubernetes objects from two release manifests, plus a few ConfigMaps that decide how every run behaves. Knowing what those objects are lets you install Tekton, check an installation someone else made, and change its behaviour safely.

## What you learned

Tekton Pipelines v1.17.1 installs with `kubectl apply` of its release manifest, pinned by version in the address. It needs Kubernetes 1.28 or later, and the Dashboard v0.73.0 needs 1.34.0 or later. The release creates the namespaces `tekton-pipelines` and `tekton-pipelines-resolvers`, the CRDs, the RBAC rules, the webhook configurations and four Deployments: the controller, the webhook, the events controller and the remote resolvers. The API server calls the webhook for every Tekton object, so Tekton objects are refused until the webhook is ready.

An installation is proved in three steps: the Deployments roll out, `pipelines-info` and `tkn version` report v1.17.1, and a TaskRun succeeds. Only the last step shows that the webhook, the controller and the steps work together.

The ConfigMap `config-defaults` sets defaults such as `default-timeout-minutes` (built-in 60) and `default-service-account` (built-in `default`). It ships with only an `_example` key, which Tekton ignores. The webhook writes the defaults into the `spec` of each TaskRun when it is created, so a change affects only new TaskRuns, and a default ServiceAccount that does not exist makes every run without its own ServiceAccount fail. The ConfigMap `feature-flags` switches features such as `enable-api-fields` and `enable-step-actions` for the whole installation.

The Tekton Dashboard installs into `tekton-pipelines` and listens on port `9097`. `release.yaml` installs it read-only; `release-full.yaml` installs it read/write and adds `edit` ClusterRoleBindings for its ServiceAccount. A port-forward opens it on `http://localhost:9097`, and `/v1/properties` reports its version, the Pipelines version and `isReadOnly`. The key facts to remember are these:

- Pin the release version in the manifest address.
- Wait for the webhook before you apply Tasks.
- Defaults are written into a TaskRun once, at creation.
- `kubectl apply` of the read-only release does not remove the `edit` bindings of the read/write release.

<!-- astrona:playground:destroy -->
