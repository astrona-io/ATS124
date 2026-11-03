---
estimated_duration: 30m
---

# Wire A Trigger To A Pipeline

- **ID:** LAB
- **Slug:** ats-124-lab-010-04
- **Author:** Paris Nakita Kejser
- **Type:** Astrona graded lab

Graded lab for the namespace `starfleet`. Read `question.md` for the task; `solution.md` is the walkthrough.

Not yet run: this lab was written from the Tekton v1.17.1 documentation and
has not passed `astrona validate` or `astrona test` yet.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-124-lab-010-04
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition, bootstrap and grading |
| `question.md` | The task |
| `solution.md` | Step-by-step walkthrough |
| `prerequisites.md` | Assumed knowledge and what the environment provides |
| `bootstrap/` | tkn CLI and Tekton Pipelines, then the starting state |
| `manifests/` | The namespace `starfleet` and the seeded objects |
| `solution/` | Reference solution used by `astrona test` |
| `testing/` | Waits for the Tekton Deployments |
| `validation/` | Grading scripts, one per check |
