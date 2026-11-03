# Summary

Tekton is a webhook, a controller and an events controller around ordinary Kubernetes objects. Knowing which of them acts at which moment tells you where a problem can be and where its evidence is.

## What you learned

The webhook runs when you apply an object. It sets defaults from `config-defaults`, refuses objects that break the API rules, and converts between API versions. When it is not running, the API server refuses new Tekton objects. The controller runs afterwards: it watches `TaskRun` and `PipelineRun` objects and their pods, queues the object's key, compares the object with the pod and the status, acts, and writes status. Because it repeats the same comparison on every pass, it recovers from a restart and starts runs that were created while it was down.

The controller has its own ServiceAccount with roles that allow it to create pods and write status. The steps run as the ServiceAccount named in `spec.serviceAccountName`, which you grant only what the Task needs. A `podTemplate` changes the pod of one run, for example its `securityContext`, and `config-defaults` can set a default for all runs.

A run leaves four signals: the condition in its status, Kubernetes events, the metrics on port 9090 of the controller, and the controller log. A failed run is read in order: reason and message, then whether a pod existed, then the step status and log, then events and the controller log. The key facts to remember are these:

- Webhook before storage, controller after storage.
- A missing Task is a failed run (`TaskRunResolutionFailed`), not a refused object, and a missing parameter is `TaskRunValidationFailed`.
- A permission belongs to one ServiceAccount, and the controller's permissions say nothing about the steps'.
- Events are kept for about an hour; the condition stays with the run.
- A failed run is not edited. Fix the cause and create a new run.

<!-- astrona:playground:destroy -->
