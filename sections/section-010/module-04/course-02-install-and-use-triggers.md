# Install And Use Triggers

Triggers installs with release manifests, like Pipelines.

## Install

<!-- astrona:playground:renew -->

Apply the Triggers release and then the interceptors:

```sh
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
```

Triggers needs Tekton Pipelines. The release adds the Triggers controller and webhook Deployments to the namespace `tekton-pipelines`, and the interceptors manifest adds the core interceptors. Check with `kubectl get pods -n tekton-pipelines`.

## A small example

Save this as `triggers.yaml`. It creates a run of a Pipeline named `deliver` whenever the listener receives a request that has a field `target`:

```yaml
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: target-binding
  namespace: starfleet
spec:
  params:
    - name: target
      value: $(body.target)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: deliver-template
  namespace: starfleet
spec:
  params:
    - name: target
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: from-trigger-
      spec:
        pipelineRef:
          name: deliver
        params:
          - name: target
            value: $(tt.params.target)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: deliver-listener
  namespace: starfleet
spec:
  serviceAccountName: trigger-sa
  triggers:
    - name: on-request
      bindings:
        - ref: target-binding
      template:
        ref: deliver-template
```

The ServiceAccount `trigger-sa` must exist and be allowed to read the Triggers objects and create `PipelineRuns`. Triggers ships two ClusterRoles for this: `tekton-triggers-eventlistener-roles` for the namespace and `tekton-triggers-eventlistener-clusterroles` for cluster-wide objects. Save this as `trigger-rbac.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: trigger-sa
  namespace: starfleet
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: trigger-sa-roles
  namespace: starfleet
subjects:
  - kind: ServiceAccount
    name: trigger-sa
    namespace: starfleet
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-roles
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: trigger-sa-clusterroles
subjects:
  - kind: ServiceAccount
    name: trigger-sa
    namespace: starfleet
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-clusterroles
```

Apply both files:

```sh
kubectl apply -f trigger-rbac.yaml
kubectl apply -f triggers.yaml
```

## Send an event

The listener's Service is `el-deliver-listener` on port 8080. Forward it and send a request:

```sh
kubectl port-forward service/el-deliver-listener 8080 -n starfleet &
curl -X POST -H 'Content-Type: application/json' -d '{"target":"orbit"}' http://localhost:8080
```

A new `PipelineRun` whose name starts with `from-trigger-` appears: `tkn pipelinerun list -n starfleet`. The Pipeline `deliver` must exist in the namespace; the playground starts without it, so create it from the earlier module first, or use the lab below, which provides it.

## Your mission: Wire A Trigger To A Pipeline

You can now install Triggers and connect an event to a run. The graded lab gives you a cluster with the Pipeline `deliver` and asks you to install Triggers and make a request start a run.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-124-playground-010-04
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-010/module-04/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-04/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-124-lab-010-04
astrona start ats-124-playground-010-04
```

## Common pitfalls

> [!WARNING]
> - **Forgetting `generateName`.** Every event would try to create the same name.
> - **A ServiceAccount without the role.** The listener answers but no run is created; read the listener's pod log.
> - **Applying the release without the interceptors manifest.** Triggers that use a core interceptor fail.
