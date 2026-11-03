# Create The TektonConfig

The `TektonConfig` is the one object that decides what the Operator installs. There is exactly one, and its name must be `config`.

## Profiles

A profile is a preset list of components:

| Profile | Components |
| --- | --- |
| `lite` | Tekton Pipelines |
| `basic` | Tekton Pipelines, Triggers and Chains |
| `all` | Everything in `basic`, plus the Dashboard |

<!-- astrona:playground:renew -->

Save this as `tektonconfig.yaml`. It asks for the smallest profile:

```yaml
apiVersion: operator.tekton.dev/v1alpha1
kind: TektonConfig
metadata:
  name: config
spec:
  profile: lite
  targetNamespace: tekton-pipelines
```

Apply it:

```sh
kubectl apply -f tektonconfig.yaml
```

`targetNamespace` is the namespace where the components are installed. Using `tekton-pipelines` gives the same layout as the release manifest install.

## Read the status

The Operator installs the components step by step. Follow it:

```sh
kubectl get tektonconfig config
kubectl get tektonpipeline
kubectl get pods -n tekton-pipelines
```

The first command shows a column for readiness. When it is ready, the Pipelines Deployments exist in `tekton-pipelines`. If it stays not ready, read the conditions:

```sh
kubectl describe tektonconfig config
```

The conditions name the component that is not ready and the reason.

## Check the installation

Everything you learned earlier applies from here. A TaskRun runs as before, and `tkn version` reports the installed Pipelines version. The difference is who owns the objects: the Operator does, and it puts them back if you change them directly.

## Common pitfalls

> [!WARNING]
> - **Naming the object anything but `config`.** The Operator works with one resource of that name.
> - **Choosing `all` on a small cluster.** More components means more pods; start with `lite` and move up.
> - **Reading only the pods.** The `TektonConfig` conditions say why a component is not ready.
