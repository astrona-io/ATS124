# Section 010: Tekton Architecture And The Execution Model

A continuous integration and delivery (CI/CD) system runs the same kind of work again and again: fetch code, build it, test it, publish it. Many CI/CD systems run that work on their own servers, outside Kubernetes. Tekton runs it inside Kubernetes, as ordinary pods, and describes it with ordinary Kubernetes objects. Once you know how Tekton turns an object into a pod, every later topic gets easier: installing Tekton, reading a failure, and using the `tkn` command-line tool.

This section shows that model at work. You first learn what Tekton is, where it comes from, and which projects make up the Tekton ecosystem. Then you run a `Task` and look inside the pod that Tekton creates for it: one container per step, a program called the entrypoint binary that puts the steps in order, and the shared folders under `/workspace` and `/tekton`. Last, you pass parameters in, read results out, and learn to read the `Succeeded` condition of a `TaskRun` when something goes wrong.

**Topic covered:** Execution model

## What you will learn

- What Tekton is: a set of Kubernetes custom resources and controllers for CI/CD, and an incubating project of the Cloud Native Computing Foundation (CNCF).
- The custom resources of Tekton Pipelines: `Task`, `TaskRun`, `Pipeline`, `PipelineRun`, `StepAction` and `CustomRun`.
- The parts of the installation: tekton-pipelines-controller, tekton-pipelines-webhook, the events controller and the remote resolvers.
- The ecosystem around Tekton Pipelines: Triggers, the `tkn` command-line tool, the Dashboard, the Catalog and Artifact Hub, Chains, the Operator, Pipelines-as-Code, Results and the Pruner.
- One pod per `TaskRun` and one container per step, and how the entrypoint binary runs the steps in order.
- Which folders the steps share (`/workspace`, `/tekton/results`) and which they do not (`/tmp`).
- Parameters, results, and the `Succeeded` condition with its reasons.

## The learning path

The section has one module. It has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The module also has its own playground, a cluster where you can explore freely, and the landing page starts it for you.

### 1. See How Tekton Runs A Task

The module starts at its landing page, which also launches the playground. The playground runs Tekton Pipelines v1.17.1, the `tkn` command-line tool and an empty namespace `starfleet` for your Tasks.

1. What Tekton Is And The Tekton Ecosystem
2. One Pod Per TaskRun, One Container Per Step
3. Parameters, Results And The Status Of A TaskRun, followed by the lab **Diagnose A Failing TaskRun**
4. Summary

## Section capstone: Repair A Multi-Step Task

The capstone is one graded scenario that combines the whole module. The `inspect` Task of the `starfleet` team never worked: its TaskRun cannot find the Task, it asks for a ServiceAccount that does not exist, and two of its steps run in the wrong order. Find each fault from the TaskRun status and the pod, fix it, and prove the fix with a TaskRun that succeeds. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-010/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-124-capstone-010
```
