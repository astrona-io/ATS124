# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Operating the installation

## Scenario

The platform team of `starfleet` wants every pod that Tekton creates to run as a normal user and to carry its own managed-by label. The Task `whoami` reports the user id of its step. The existing run `before` reports `0`, because the image runs as root.

## Your task

1. In the installation, set the default managed-by label value of Tekton pods to `starfleet-ci`.
2. In the installation, set a default pod template that makes every step run as user id `1000`, group id `1000`.
3. Create a new `TaskRun` named `after` in the namespace `starfleet` that uses the Task `whoami`, and make sure it succeeds.

## Constraints

- Change the defaults only in the ConfigMap `config-defaults` in the namespace `tekton-pipelines`. Do not set a `podTemplate` in the Task or in any `TaskRun`.
- Do not remove the `_example` key or any other key of `config-defaults`.
- Do not delete or recreate the `TaskRun` `before`.
- `after` must refer to the Task with `taskRef`.

## Done when

- `config-defaults` has `default-managed-by-label-value` set to `starfleet-ci`, and a `default-pod-template` that sets `runAsUser` and `runAsGroup` to `1000`.
- The `TaskRun` `after` has `Succeeded` = `True`, its result `uid` is `1000`, and its pod has the label `app.kubernetes.io/managed-by` set to `starfleet-ci`.
- The `TaskRun` `before` still exists and still reports the result `uid` as `0`.
- A new run of `whoami`, created by the grader without any pod template, also reports `1000`.
