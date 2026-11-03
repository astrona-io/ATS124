# Summary

Operating Tekton means knowing which ConfigMap controls which behaviour, and who owns that ConfigMap. The controller, the webhook and the events controller each watch their ConfigMaps and apply a change without a restart.

## What you learned

`config-logging` sets the log level per component (`loglevel.controller`, `loglevel.webhook`), and `debug` is for a short investigation only. `config-observability` decides where metrics go and how detailed the `TaskRun` and `PipelineRun` metrics are. Tekton stores no step logs: they live in the pod until the pod is gone, so a cluster needs a log collector if it must keep them.

The controller scales out with leader election. Replicas share work through Lease objects, with timers in `config-leader-election-controller` and a `buckets` value that divides the work between replicas. Set `buckets` equal to the number of replicas. When a leader fails, another replica takes its Lease after about the lease duration. The webhook has no leader to wait for, and a HorizontalPodAutoscaler scales it.

`config-defaults` shapes every new run: `default-pod-template` sets pod settings such as the user, and `default-managed-by-label-value` sets the `app.kubernetes.io/managed-by` label on pods. The webhook writes defaults at creation, so old runs keep their values. A ResourceQuota limits a namespace; the controller treats a refused pod as temporary and keeps trying. Tekton keeps the largest step request in a pod because steps run in sequence. On an Operator-managed cluster the `TektonConfig` named `config` owns the ConfigMaps, and manual edits are overwritten. The key facts to remember are these:

- A ConfigMap change reaches the running Deployment without a restart, but only new runs get new defaults.
- Set `buckets` to the number of controller replicas.
- Delete only the leading pod to test a failover.
- Tekton does not store step logs.
- With the Operator, change `TektonConfig`, not the ConfigMaps.

<!-- astrona:playground:destroy -->
