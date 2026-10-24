# Install The Tekton Dashboard

`kubectl` and `tkn` show one object at a time. When a team runs hundreds of TaskRuns a day, people want a page where they can see every run, its steps and its logs at a glance. The Tekton Dashboard is that page. It is also a component with real permissions in your cluster, so how you install it matters. This part installs the Dashboard in read-only mode, opens it, and compares it with the read/write release.

## Two releases: read-only and read/write

The Tekton Dashboard is a web interface for Tekton objects. It runs as one Deployment, `tekton-dashboard`, in the namespace `tekton-pipelines`, and it reads Tekton objects through the Kubernetes API with its own ServiceAccount. Each Dashboard release publishes two manifests:

| Manifest | Mode | What the Dashboard may do |
| --- | --- | --- |
| `release.yaml` | Read-only (`--read-only=true`) | Show Tekton objects, pods and logs. No create, rerun, cancel or delete |
| `release-full.yaml` | Read/write (`--read-only=false`) | Everything above, plus create, rerun, cancel, delete and edit runs and Tasks |

The difference is not only a flag. The read/write release also creates ClusterRoleBindings, `tekton-dashboard-backend-edit`, `tekton-dashboard-pipelines-edit` and `tekton-dashboard-triggers-edit`, that give the Dashboard's ServiceAccount the right to change objects in every namespace. The Dashboard has no login of its own, so anyone who can reach it can use those rights. That is why the read-only release is the default, and the one you install here.

## Install and check the read-only Dashboard

The Dashboard v0.73.0 supports Tekton Pipelines v1.15 and v1.17, and it needs Kubernetes 1.34.0 or later. Apply its read-only manifest:

<!-- astrona:playground:renew -->

```sh
kubectl apply -f https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.73.0/release.yaml
```

`kubectl` creates a CRD for Dashboard extensions, a ServiceAccount, ClusterRoles and their bindings, the ConfigMap `dashboard-info`, a Service and a Deployment, all named `tekton-dashboard` where they have a name of their own. Wait for the Deployment:

```sh
kubectl -n tekton-pipelines rollout status deployment/tekton-dashboard
```

The command ends with a line that the Deployment was rolled out. `tkn version` now also finds the Dashboard, because it reads the version from the ConfigMap `dashboard-info`:

```sh
tkn version
```

The output adds a Dashboard version line with v0.73.0.

## Open the Dashboard

The Dashboard Service has no external address; it listens on port `9097` inside the cluster. A port-forward makes it reachable from your machine. Start it in a second terminal and leave it running:

```sh
kubectl -n tekton-pipelines port-forward svc/tekton-dashboard 9097:9097
```

Open `http://localhost:9097` in your browser. The menu lists Tekton kinds such as PipelineRuns, TaskRuns and Tasks. Choose the namespace `starfleet` and open the TaskRun `install-check`. You see its step, its status and its log, which the Dashboard reads from the step container of the pod. There is no button to create, rerun or delete the run, because this is the read-only release.

The Dashboard also answers a small API that reports how it runs. With the port-forward still running, ask it from your first terminal:

```sh
curl -s http://localhost:9097/v1/properties
```

The JSON answer holds, among other fields, `"dashboardVersion":"v0.73.0"`, `"pipelinesVersion":"v1.17.1"` and `"isReadOnly":true`. The Dashboard found the Pipelines version the same way `tkn` did, in `pipelines-info`. That one request is a quick way to check the mode of any Dashboard you meet.

## What read/write would change

Look at what the Dashboard's ServiceAccount is allowed to do now. The read-only release binds it to ClusterRoles that only allow reading:

```sh
kubectl get clusterrolebindings -l rbac.dashboard.tekton.dev/subject=tekton-dashboard
```

The list holds view bindings such as `tekton-dashboard-backend-view` and `tekton-dashboard-pipelines-view`, and no binding with `edit` in its name. If someone applied `release-full.yaml` over it, the `edit` bindings would appear and `isReadOnly` would turn `false`. Applying `release.yaml` again would change the flag back, but `kubectl apply` never deletes objects that are missing from a file, so the `edit` bindings would stay until you delete them. To switch from read/write back to read-only cleanly, delete the full release with `kubectl delete -f` on the same address, then apply the read-only release.

You can now install the Tekton Dashboard in read-only mode, open it with a port-forward on port `9097`, and check its mode and versions through `/v1/properties`. You also know what the read/write release adds and how to remove it again. With Tekton Pipelines, its defaults and the Dashboard in place, the installation is complete; what is left is to practise finishing one that someone else started.

## Common pitfalls

> [!WARNING]
> - **Installing `release-full.yaml` by habit.** It gives a Dashboard without login the right to change runs in every namespace. Use `release.yaml` unless you have a reason and an authentication proxy in front.
> - **Re-applying `release.yaml` to undo `release-full.yaml`.** The flag changes, but the `edit` ClusterRoleBindings stay. Delete the full release first.
> - **Looking for the Dashboard in its own namespace.** Both releases install it in `tekton-pipelines`.
> - **Closing the port-forward.** The browser then shows a connection error. Start the port-forward again.

## Your mission: Finish A Tekton Installation

You can now install Tekton Pipelines and the Dashboard, change defaults in `config-defaults`, and prove an installation with a TaskRun. The graded lab gives you an installation that someone started and did not finish: the Dashboard is missing, and the defaults do not match the team's rules. Finish it and prove it with a TaskRun.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-124-playground-020-01
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-020/module-01/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-01/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-124-lab-020-01
astrona start ats-124-playground-020-01
```
