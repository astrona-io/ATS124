---
estimated_duration: 20m
---

# Finish A Tekton Installation

- **ID:** LAB
- **Slug:** ats-124-lab-020-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona graded lab

Graded lab for the namespaces `tekton-pipelines` and `starfleet`. Read `question.md` for the task; `solution.md` is the walkthrough.

Not yet run: this lab was written from the Tekton v1.17.1 documentation and
has not passed `astrona validate` or `astrona test` yet.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-124-lab-020-01
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-124-lab-020-01`), not
the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition, bootstrap and grading |
| `question.md` | The task |
| `solution.md` | Step-by-step walkthrough |
| `prerequisites.md` | Assumed knowledge and what the environment provides |
| `bootstrap/` | tkn CLI and Tekton Pipelines without the Dashboard, then the changed defaults and the Task `install-check` |
| `manifests/` | The namespace `starfleet` and the Task `install-check` |
| `solution/` | Reference solution used by `astrona test`, with the proof TaskRun |
| `testing/` | Waits for the Tekton Deployments |
| `validation/` | Grading scripts, one per check; `validate-defaults.sh` runs its own TaskRun |
