# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** Installing Tekton with the Operator

## Scenario

The cluster is empty. The platform team of `starfleet` wants Tekton Pipelines installed and managed by the Tekton Operator, with a default run timeout of 30 minutes.

## Your task

1. Install the Tekton Operator from its release manifest.
2. Create the `TektonConfig` named `config` with the profile `lite` and the target namespace `tekton-pipelines`.
3. Set the Pipelines default timeout to 30 minutes through the `TektonConfig`.
4. When Tekton is ready, create a `TaskRun` in the namespace `starfleet` with an embedded task that prints a line, and make sure it succeeds.

## Constraints

- Do not install Tekton Pipelines from its own release manifest.
- Change the timeout only through the `TektonConfig`, not by editing `config-defaults`.

## Done when

- The Deployments `tekton-operator` and `tekton-operator-webhook` in the namespace `tekton-operator` are available.
- The `TektonConfig` `config` has the profile `lite`, the target namespace `tekton-pipelines`, `spec.pipeline.default-timeout-minutes` set to 30, and is ready.
- A new `TaskRun` created by the grader in `starfleet` succeeds and has a timeout of 30 minutes.
