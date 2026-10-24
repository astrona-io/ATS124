# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Installation

## Scenario

A colleague started to install Tekton for the `starfleet` team and went on holiday. Tekton Pipelines v1.17.1 runs, but nobody installed the Dashboard, and the colleague changed `config-defaults` while testing. The team's rules for this cluster are short:

- People may look at runs in the Tekton Dashboard, but nobody may change or delete runs from it.
- A TaskRun that does not name a ServiceAccount runs as the ServiceAccount `default` of its namespace.
- A TaskRun that does not set a timeout is stopped after 20 minutes.

## Your task

1. Install the Tekton Dashboard v0.73.0 so that it follows the team's rules.
2. Change the Tekton defaults so that they follow the team's rules.
3. Prove the installation: create a TaskRun named `install-check-run` in `starfleet` that runs the Task `install-check` and succeeds.

## Constraints

- Install the Dashboard from its official v0.73.0 release manifest, into `tekton-pipelines`.
- Change the defaults in the ConfigMap `config-defaults`. Do not create a ServiceAccount named `tekton-builder`.
- Do not reinstall or upgrade Tekton Pipelines.
- `install-check-run` must refer to the Task with `taskRef` and set neither `timeout` nor `serviceAccountName`: both must come from the defaults.

## Done when

- The four Tekton Pipelines Deployments are Available, and `pipelines-info` still reports v1.17.1.
- The Deployment `tekton-dashboard` is Available, and the Dashboard reports version v0.73.0, read-only mode and Pipelines v1.17.1.
- A new TaskRun without `timeout` and `serviceAccountName` gets `spec.timeout` `20m0s` and `spec.serviceAccountName` `default`, and succeeds.
- `install-check-run` succeeded with those values and reports the result `status` = `ok`.
