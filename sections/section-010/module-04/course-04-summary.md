# Summary

Triggers and Chains extend Tekton Pipelines on both sides of a run.

## What you learned

Triggers turns an HTTP request into a `PipelineRun` through an `EventListener`, an optional interceptor, a `TriggerBinding` that reads values and a `TriggerTemplate` that builds the objects. It installs from a release manifest and an interceptors manifest. Chains watches finished runs, signs a record of them with a key from the secret `signing-secrets`, and marks the run with the annotation `chains.tekton.dev/signed`. The key facts to remember are these:

- Triggers starts runs; Chains signs them afterwards.
- A listener without an interceptor starts runs for anyone who can reach it.
- Chains signs only runs it sees finish.

<!-- astrona:playground:destroy -->
