# Solution: Repair A Broken Tekton Installation

Work the task yourself first. Running `astrona submit -c sections/section-020/capstone/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the four Tekton Deployments are ready and the webhook admits a Task; the Dashboard is read-only with no `edit` ClusterRoleBinding left; and `smoke-run` succeeded while a new TaskRun also starts and succeeds.

## Step 1: Reproduce the refusal

Save the Task from the task description as `task-smoke.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: smoke
  namespace: starfleet
spec:
  params:
    - name: crew
      type: string
  results:
    - name: message
      description: One line that names the crew member
  steps:
    - name: smoke
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        set -eu
        printf 'smoke test passed for %s' "$(params.crew)" | tee "$(results.message.path)"
```

Apply it:

```sh
kubectl apply -f task-smoke.yaml
```

The API server refuses it. The error says that calling the webhook `webhook.pipeline.tekton.dev` failed, because the Service `tekton-pipelines-webhook` has no endpoints. The Task is fine; the API server must ask the webhook before it stores a Tekton object, and nothing answers.

## Step 2: Find the stopped components

List the Deployments:

```sh
kubectl get deployments -n tekton-pipelines
kubectl get deployments -n tekton-pipelines-resolvers
```

`tekton-pipelines-webhook` and `tekton-pipelines-controller` show `0/0`: someone scaled them to zero. Without the webhook, no Tekton object can be created or changed. Without the controller, a `TaskRun` would be stored but would never get a pod or a status. Scale both back:

```sh
kubectl -n tekton-pipelines scale deployment tekton-pipelines-webhook --replicas=1
kubectl -n tekton-pipelines scale deployment tekton-pipelines-controller --replicas=1
kubectl -n tekton-pipelines rollout status deployment/tekton-pipelines-webhook
kubectl -n tekton-pipelines rollout status deployment/tekton-pipelines-controller
```

Both rollouts end with a line that the Deployment was rolled out. The webhook also has a HorizontalPodAutoscaler with at least one replica, but an autoscaler does nothing while a Deployment is scaled to zero, so it could not bring the webhook back by itself.

## Step 3: Run the smoke test

Apply the Task again. If the webhook has only just started, the first attempt can still fail; wait a few seconds and repeat it.

```sh
kubectl apply -f task-smoke.yaml
```

Save the TaskRun from the task description as `taskrun-smoke-run.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: smoke-run
  namespace: starfleet
spec:
  taskRef:
    name: smoke
  params:
    - name: crew
      value: probe
```

Apply it:

```sh
kubectl apply -f taskrun-smoke-run.yaml
```

Then check the result:

```sh
kubectl wait --for=condition=Succeeded taskrun/smoke-run -n starfleet --timeout=180s
kubectl get taskrun smoke-run -n starfleet -o jsonpath='{.status.results[?(@.name=="message")].value}{"\n"}'
```

It prints `smoke test passed for probe`.

## Step 4: Find out how the Dashboard runs

Ask the Dashboard for its properties through the Kubernetes API server:

```sh
kubectl get --raw /api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/v1/properties
kubectl get clusterrolebindings -l rbac.dashboard.tekton.dev/subject=tekton-dashboard
```

The JSON shows `"isReadOnly":false`, and the list of bindings includes `tekton-dashboard-backend-edit`, `tekton-dashboard-pipelines-edit` and `tekton-dashboard-triggers-edit`. Someone installed `release-full.yaml`.

## Step 5: Switch the Dashboard to read-only

Applying `release.yaml` on top would change the flag, but `kubectl apply` never deletes objects, so the three `edit` bindings would stay and the Dashboard's ServiceAccount would keep its rights. Delete the full release first, then apply the read-only release:

```sh
kubectl delete -f https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.73.0/release-full.yaml
kubectl apply -f https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.73.0/release.yaml
kubectl -n tekton-pipelines rollout status deployment/tekton-dashboard
```

Then check the result with the same two commands as in Step 4. The JSON now shows `"isReadOnly":true`, and only `view` bindings are left.

## Step 6: Submit

```sh
astrona submit -c sections/section-020/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Delete the webhook configurations so that objects are accepted | Tekton objects are no longer checked or defaulted; the task forbids it, and TaskRuns without defaults misbehave |
| Scale only the webhook | Tasks are accepted, but no TaskRun ever gets a pod; the grader's own TaskRun never ends |
| Apply `release.yaml` over the full release | `isReadOnly` turns `true`, but the `edit` ClusterRoleBindings stay. The grader rejects it |
| Reinstall Tekton Pipelines | The replica counts may come back, but the task forbids it, and a reinstall hides what went wrong |

## Common mistakes

- Reading the webhook error as a fault in the YAML. The message names the webhook and its Service, not a field.
- Expecting the HorizontalPodAutoscaler to restore the webhook. It does not act on a Deployment with zero replicas.
- Applying the Task in the same second the webhook starts. Wait for the rollout, then retry once.

## Practice on your own

- Scale only the controller to zero, create a TaskRun, and read its status. Compare it with a TaskRun created while the webhook is down.
- Use `tkn version` before and after the Dashboard switch, and note which lines change.
