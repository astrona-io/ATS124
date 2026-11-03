# Meet Triggers And Chains

Tekton Pipelines runs work when someone creates a `PipelineRun`. Two sibling projects handle what comes before and after: **Triggers** creates runs from events such as a webhook call, and **Chains** signs what the runs produce. This module introduces both.

## Learning objectives

After this module you can:

- Name the objects of Triggers and say what each one does.
- Describe the path from an HTTP request to a `PipelineRun`.
- Say what Chains records about a finished run and where it stores it.
- Choose which of the two projects solves a given problem.

## Before you start

You need to know `Pipeline`, `PipelineRun` and the custom resource idea. Your playground is a single-node `kind` cluster with Tekton Pipelines v1.17.1, the `tkn` command-line tool and an empty namespace `starfleet`. Triggers and Chains are not installed: installing them is part of the work.

The module has three parts. **Triggers: From Event To Run** covers the objects. **Install And Use Triggers** shows the install and a small example, followed by a graded lab. **Chains: Sign What Runs Produce** covers signing.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
