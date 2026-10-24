# ATS124 — Fundamentals, Architecture & tkn CLI (Tekton)

Course material for the **Fundamentals, Architecture & tkn CLI** domain of
the Astrona Tekton training path ([ATP024](https://github.com/astrona-io/ATP024)),
which is **10% of the path**. Written for **Tekton Pipelines v1.17.1**, the
**Tekton Dashboard v0.73.0** and the **tkn CLI v0.46.2**.

> **Status: draft, not yet run.** Every page, playground and lab was written
> from the Tekton documentation, the v1.17.1 and v0.73.0 release manifests and
> the source at the pinned tags. None has been started on a cluster, and no
> lab has passed `astrona test` yet. See `CLAUDE.md`.

Tekton is an incubating project of the Cloud Native Computing Foundation
(CNCF) since March 2026; before that it was a graduated project of the
Continuous Delivery Foundation. There is no official Tekton certification
exam; the path's domains and weights are Astrona's own.

The course opens with an Introduction in `sections/intro/` (welcome, machine setup,
how the course is made). Everything else lives under `sections/`. Each section
contains:

- **Modules** — a reading chapter split into a short landing page, ordered
  deep-dive parts and a summary page, a throwaway **playground** to explore in,
  and a graded **lab** placed right after the part it tests.
- **A capstone** — one larger graded lab combining that section's modules into a
  single scenario with several independent faults.

---

## Sections

| Section | Title | Modules | Labs | Topic |
| --- | --- | --- | --- | --- |
| [010](sections/section-010) | Tekton Architecture And The Execution Model | 1 | 1 + capstone | Execution model |
| [020](sections/section-020) | Install Tekton Pipelines And The Dashboard | 1 | 1 + capstone | Installation |
| [030](sections/section-030) | Run And Inspect Work With The tkn CLI | 1 | 1 + capstone | tkn CLI |

The order goes from model to installation to daily use. Section 010 starts
on a cluster where Tekton already runs and shows how a `TaskRun` becomes a pod
with one container per step. Section 020 installs Tekton Pipelines, its
defaults and the Dashboard on an empty cluster, which is easier to follow once
you know what the components do. Section 030 ends with the `tkn`
command-line tool, used against a complete installation.

---

## Modules

| Module | Reader | Parts | Labs |
| --- | --- | --- | --- |
| 010-01 | [See How Tekton Runs A Task](sections/section-010/module-01/course.md) | 3 | [lab-01](sections/section-010/module-01/labs/lab-01) |
| 020-01 | [Install And Configure Tekton](sections/section-020/module-01/course.md) | 3 | [lab-01](sections/section-020/module-01/labs/lab-01) |
| 030-01 | [Run And Inspect Work With tkn](sections/section-030/module-01/course.md) | 3 | [lab-01](sections/section-030/module-01/labs/lab-01) |

| Lab | Title | Kind | Faults or work |
| --- | --- | --- | --- |
| 010-01 | Diagnose A Failing TaskRun | troubleshooting | a wrong parameter name in the TaskRun, steps sharing a file through `/tmp` |
| 020-01 | Finish A Tekton Installation | build | Dashboard missing, `config-defaults` with a missing ServiceAccount and a 90-minute timeout |
| 030-01 | Run A Parameterised Task With tkn | build | the same Task name in `starfleet` and `default`, a stray run in `default` |

---

## Capstones

| Capstone | Scenario | Faults |
| --- | --- | --- |
| [010](sections/section-010/capstone/labs/lab-01) | Repair A Multi-Step Task | the Task in the wrong namespace, a missing ServiceAccount, two steps in the wrong order |
| [020](sections/section-020/capstone/labs/lab-01) | Repair A Broken Tekton Installation | the webhook and the controller scaled to zero, the read/write Dashboard installed |
| [030](sections/section-030/capstone/labs/lab-01) | Triage And Rerun Work With tkn | two failed runs among four; record the failed step and version, delete only the failures, start a two-parameter run |

---

## The lab environment

Every playground and lab is a single-node **kind** cluster (Kubernetes 1.34
or later, because of the Dashboard) with the `tkn` CLI 0.46.2 installed on the
machine and an empty namespace `starfleet`. Tekton Pipelines v1.17.1 is
installed from its release manifest, except in the section 020 playground,
where installing it is the lesson. The Dashboard v0.73.0 is installed in the
section 030 playground (read-only) and the section 020 capstone (read/write,
as the fault). Step images use `busybox:1.37.0`, preloaded on the node.
Tekton's own images come from `ghcr.io` (and the `place-scripts` shell image
from `cgr.dev`) by digest, so every start needs outbound internet.

Graders read Tekton objects with `kubectl`, read the Dashboard through the
API server's Service proxy, and often create a TaskRun of their own
(`generateName`, label `astrona.io/grader: "true"`) to test behaviour. No
script uses a fixed host port.

## Running a playground

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/<section>/<module>/playground
astrona destroy <name>
```

## Running a lab

Labs and capstones are graded. Read `question.md`, do the work, and submit:

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/<section>/<module>/labs/lab-01
astrona submit -c sections/<section>/<module>/labs/lab-01
astrona destroy <name>
```

Each lab grades the **final cluster state** with independent checks, and
several of them deliberately reject the plausible-but-wrong fix (embedding the
steps with `taskSpec`, merging steps, creating a missing ServiceAccount instead
of fixing the default, applying the read-only Dashboard over the read/write one,
running in the wrong namespace, deleting every TaskRun).
