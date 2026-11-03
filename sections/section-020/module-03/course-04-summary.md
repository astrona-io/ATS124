# Summary

The Operator turns one object into a Tekton installation.

## What you learned

You install the Operator with its release manifest, which adds the namespace `tekton-operator`, two Deployments and the CRDs. You create the `TektonConfig` named `config` with a profile: `lite`, `basic` or `all`. The Operator installs the components in `targetNamespace` and shows readiness in the status. You change Pipelines settings under `spec.pipeline`, upgrade by applying a newer Operator release, and remove by deleting the `TektonConfig` before the Operator. The key facts to remember are these:

- The Operator installs nothing until a `TektonConfig` named `config` exists.
- Settings belong in `TektonConfig`, not in the ConfigMaps.
- Delete the `TektonConfig` first, the Operator second.

<!-- astrona:playground:destroy -->
