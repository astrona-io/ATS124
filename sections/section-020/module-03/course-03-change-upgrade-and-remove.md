# Change, Upgrade And Remove

Day-two work with the Operator happens on the `TektonConfig`, not in the ConfigMaps.

## Change a setting

<!-- astrona:playground:renew -->

The Pipelines settings are fields under `spec.pipeline`. Their names follow the keys of `config-defaults` and `feature-flags`. Edit the object:

```sh
kubectl edit tektonconfig config
```

In the editor, add a field under `spec`:

```yaml
spec:
  pipeline:
    default-timeout-minutes: 30
```

Save and close. The Operator writes the value into `config-defaults`. Check it:

```sh
kubectl get configmap config-defaults -n tekton-pipelines -o jsonpath='{.data.default-timeout-minutes}{"\n"}'
```

As in the earlier module, only runs created afterwards get the new default.

## Add a component

Change the profile, for example from `lite` to `basic`. The Operator then installs Triggers and Chains. The same edit with `kubectl edit tektonconfig config` works.

## Upgrade

You upgrade the Operator, not the components. Apply the release manifest of a newer Operator. The Operator then moves the components to the versions that release carries. Read the release notes of the Operator first.

## Remove

Delete the `TektonConfig` first, so the Operator removes the components in an orderly way:

```sh
kubectl delete tektonconfig config
```

Wait until the components are gone, then delete the Operator with the manifest you installed it with. Removing the Operator first leaves components that nobody manages.

You can now install, configure, upgrade and remove Tekton with the Operator.

## Your mission: Install Tekton With The Operator

You can now install, configure, upgrade and remove Tekton with the Operator. The graded lab gives you an empty cluster and asks you to install the Operator, create the `TektonConfig` and prove that a run gets the default you set.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-124-playground-020-03
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-020/module-03/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-03/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-124-lab-020-03
astrona start ats-124-playground-020-03
```

## Common pitfalls

> [!WARNING]
> - **Editing `config-defaults` directly.** The Operator writes its value back.
> - **Deleting the Operator before the `TektonConfig`.** The components stay behind.
> - **Upgrading Tekton Pipelines by its own manifest.** The Operator undoes it.
