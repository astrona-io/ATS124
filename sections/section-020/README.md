# Section 020: Install Tekton Pipelines And The Dashboard

Every Tekton cluster starts with an installation, and many Tekton problems start there too: a webhook that is not ready yet, a default that someone changed, a Dashboard that can change more than it should. If you know what the installation creates and where its settings live, you can check an installation in minutes instead of guessing.

This section installs Tekton on an empty `kind` cluster, the way the Tekton documentation does it. You first apply the release manifest of Tekton Pipelines, follow what it creates, and prove that it works with a TaskRun. Then you change the defaults in the ConfigMap `config-defaults` and read the switches in `feature-flags`. Last, you install the Tekton Dashboard in read-only mode and open it with a port-forward.

**Topic covered:** Installation

## What you will learn

- Installing Tekton Pipelines v1.17.1 from its release manifest, and the Kubernetes version it needs.
- What the release creates: the namespaces `tekton-pipelines` and `tekton-pipelines-resolvers`, four Deployments, the CRDs, the webhook configurations and the ConfigMaps.
- Verifying an installation: Deployment rollout, the version in `pipelines-info`, `tkn version`, and a TaskRun that succeeds.
- Changing defaults in `config-defaults` (`default-timeout-minutes`, `default-service-account`) and when a change takes effect.
- Reading `feature-flags`: `enable-api-fields`, `enable-step-actions`, `set-security-context` and others.
- Installing the Tekton Dashboard v0.73.0 from `release.yaml` (read-only) or `release-full.yaml` (read/write), and opening it on port `9097`.

## The learning path

The section has one module. It has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The module also has its own playground, a cluster where you can explore freely, and the landing page starts it for you.

### 1. Install And Configure Tekton

The module starts at its landing page, which also launches the playground. The playground holds only the `tkn` command-line tool and an empty namespace `starfleet`. Tekton itself is not installed: installing it is what you do in the parts.

1. Install Tekton Pipelines From The Release Manifest
2. Configure Defaults And Feature Flags
3. Install The Tekton Dashboard, followed by the lab **Finish A Tekton Installation**
4. Summary

## Section capstone: Repair A Broken Tekton Installation

The capstone is one graded scenario that combines the whole module. Someone "cleaned up" the Tekton installation of the `starfleet` team: TaskRuns no longer start, no Task can be applied, and the Dashboard lets anyone change and delete runs although the team asked for a read-only Dashboard. Find out which component stopped and why, bring the installation back, and prove it with a TaskRun. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-020/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-124-capstone-020
```
