# Overview: Meet Triggers And Chains (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Tekton Pipelines and the `tkn` command-line tool, and gives you an empty namespace `starfleet`. Triggers and Chains are not installed. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Tekton Pipelines v1.17.1**, installed from its release manifest.
- The Tekton command-line tool `tkn`, version **0.46.2**, on your PATH.
- An empty namespace `starfleet`.
- The image `busybox:1.37.0`, already loaded on the node.

The cluster needs outbound internet, because Triggers and Chains are downloaded.

## Practice tasks

- Install Triggers and its interceptors, and list the new CRDs.
- Create the Pipeline `deliver` from the earlier modules, then the binding, template and listener, and send a request with `curl`.
- Send a request with a body that has no `target` and read what the listener does.
- Install Chains, create the signing secret with `cosign`, and run a TaskRun.
- Read the annotations of the finished TaskRun.
