# Install Tekton With The Operator

The Tekton Operator installs and manages Tekton components from one resource, the `TektonConfig`. Instead of applying a release manifest per component, you install the Operator once, choose a profile, and the Operator installs Tekton Pipelines, and optionally Triggers, Chains and the Dashboard.

Your playground is a single-node `kind` cluster with the `tkn` command-line tool and an empty namespace `starfleet`. Tekton is not installed: the Operator does that. Allow several minutes for the components to start.

## Learning objectives

After this module you can:

- Install the Operator from its release manifest and check that it runs.
- Choose a profile (`lite`, `basic` or `all`) and create the `TektonConfig` named `config`.
- Read the status of a `TektonConfig` and of the components it installs.
- Change a Pipelines setting through `spec.pipeline`.
- Upgrade and remove an Operator-managed installation.

## Before you start

You need to know the release manifest install, `config-defaults` and the idea of a custom resource. The previous module explained who owns a setting when an operator is present. This module shows the steps.

The module has three parts. **Install The Operator** applies the release manifest. **Create The TektonConfig** chooses a profile and reads the status. **Change, Upgrade And Remove** covers day-two work, followed by a graded lab.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
