# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** Triggers

## Scenario

The namespace `starfleet` has the Pipeline `deliver`, which needs a parameter `target`. The team wants an HTTP request with the body `{"target":"orbit"}` to start a run of it. Tekton Triggers is not installed.

## Your task

1. Install Tekton Triggers and its interceptors from the release manifests.
2. In `starfleet`, create the ServiceAccount `trigger-sa` and give it the two Triggers ClusterRoles for event listeners.
3. Create the `TriggerBinding` `target-binding`, the `TriggerTemplate` `deliver-template` and the `EventListener` `deliver-listener`. The template creates a `PipelineRun` of `deliver` with `generateName` `from-trigger-` and the parameter `target` taken from the request body.
4. Send the request to the listener and let the run finish.

## Constraints

- Do not create the `PipelineRun` yourself. The listener must create it.
- The listener must run as `trigger-sa`.

## Done when

- The Triggers controller, webhook and core interceptors Deployments are available in `tekton-pipelines`.
- `trigger-sa`, `target-binding`, `deliver-template` and `deliver-listener` exist in `starfleet`, and the listener uses `trigger-sa`.
- A `PipelineRun` whose name starts with `from-trigger-` ran the Pipeline `deliver` with `target` set to `orbit` and has `Succeeded` = `True`.
