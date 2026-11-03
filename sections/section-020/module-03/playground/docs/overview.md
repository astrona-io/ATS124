# Overview: Install Tekton With The Operator (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the `tkn` command-line tool and an empty namespace `starfleet`. Tekton is not installed. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- The Tekton command-line tool `tkn`, version **0.46.2**, on your PATH.
- An empty namespace `starfleet`.
- The image `busybox:1.37.0`, already loaded on the node.

The cluster needs outbound internet, because the Operator and the components it installs are downloaded.

## Practice tasks

- Install the Operator and list its Deployments and CRDs.
- Create a `TektonConfig` named `config` with the profile `lite` and read its conditions while it installs.
- Change `default-timeout-minutes` under `spec.pipeline` and read `config-defaults`.
- Edit `config-defaults` by hand and watch the Operator write the old value back.
- Change the profile to `basic` and list the new Deployments.
- Delete the `TektonConfig` and watch the components go away.
