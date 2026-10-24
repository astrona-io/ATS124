# Overview: Run And Inspect Work With tkn (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Tekton Pipelines, the read-only Tekton Dashboard and the `tkn` command-line tool, and gives you an empty namespace for your own Tasks. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` and `tkn` already point at it.
- **Tekton Pipelines v1.17.1** in `tekton-pipelines` and `tekton-pipelines-resolvers`.
- The **Tekton Dashboard v0.73.0**, read-only, in `tekton-pipelines`, listening on port `9097` inside the cluster.
- The Tekton command-line tool `tkn`, version **0.46.2**, on your PATH. It is a client of the Kubernetes API server and uses your kubeconfig, like `kubectl`.
- An empty namespace `starfleet` for your Tasks and TaskRuns.
- The image `busybox:1.37.0`, already loaded on the node, for your steps.

To watch your runs in a browser, start a port-forward in a second terminal and open `http://localhost:9097`:

```sh
kubectl -n tekton-pipelines port-forward svc/tekton-dashboard 9097:9097
```

## Helpers

Paste these once in each new terminal. `runs` lists the TaskRuns in `starfleet`. `last_run` describes the newest TaskRun there. `last_logs` prints the logs of the newest TaskRun there.

```sh
runs() {
  tkn taskrun list -n starfleet
}
last_run() {
  tkn taskrun describe --last -n starfleet
}
last_logs() {
  tkn taskrun logs --last -n starfleet
}
```

Use them like this: `runs`, `last_run`, `last_logs`.

## Practice tasks

- Apply a Task `hello` with the parameter `crew` to both `starfleet` and `default`, but with different greetings. Run `tkn task start hello -p crew=probe --showlog` with and without `-n starfleet`, and explain which Task ran each time.
- Make a kubeconfig context `starfleet` with the default namespace `starfleet`, use it with `--context`, then delete it again with `kubectl config delete-context starfleet`.
- Start a Task without `-p` for a parameter that has no default and answer the prompt. Then try the same with `--use-param-defaults` on a parameter that has a default.
- Save the output of `tkn task start hello -n starfleet -p crew=scout --dry-run --output yaml` to a file and create it with `kubectl create -f`.
- Start five runs of `hello`, then delete all but the newest two with `tkn taskrun delete --task hello --keep 2 -n starfleet -f`. Check the result in the Dashboard.
- Compare `tkn taskrun logs --last -a -n starfleet` with `kubectl logs` of the pod's init containers.
