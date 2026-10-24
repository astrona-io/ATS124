# Welcome To The Course

This course trains you for the **Fundamentals, Architecture & tkn CLI** part of the Astrona **Tekton** training path. That part is 10% of the path. This page tells you who the course is for, what you can do at the end, which words and example setup it uses, and how its pages fit together.

## Who this course is for

You know your way around Kubernetes: namespaces, pods, containers, ConfigMaps, ServiceAccounts, `kubectl apply`, `kubectl get` and `kubectl logs`. You know what a kubeconfig file is. You do not need to know Tekton or any other continuous integration and delivery (CI/CD) system yet. Each new idea is explained the first time it appears.

## What you can do at the end

Tekton runs CI/CD work as pods in Kubernetes, so this course does not ask you to remember words. It asks you to install Tekton, run Tasks, read what happened, and find out why when a run fails. The course has three topics, and each one turns into a set of skills you will practise.

The first topic is **Tekton's architecture and execution model**. You will learn to:

- Explain what Tekton is and name the projects of the Tekton ecosystem.
- Name the custom resources of Tekton Pipelines and the components that act on them.
- Find the pod of a `TaskRun`, its step containers, and the folders the steps share.
- Pass parameters, read results, and read the status of a failed `TaskRun`.

Tekton has to be installed before it can run anything, so the second topic is **installing Tekton Pipelines and the Dashboard**. You will learn to:

- Install Tekton Pipelines from its release manifest and verify the installation.
- Change defaults in `config-defaults` and read `feature-flags`.
- Install the Tekton Dashboard in read-only mode and open it in a browser.

The third topic is **the `tkn` command-line tool**. You will learn to:

- Install `tkn` and control which cluster and namespace it works in.
- Start Tasks with parameters and follow their logs.
- Describe, read and clean up TaskRuns.

Everything is written for **Tekton Pipelines v1.17.1**, the **Tekton Dashboard v0.73.0** and **tkn v0.46.2**.

## The words this course uses

The pages use Tekton's and Kubernetes' own terms, because those are the words you meet in the product, the logs and the documentation. Each term gets a short, plain definition the first time it appears on a page. A few terms come back on almost every page, so here they are up front.

A **custom resource definition (CRD)** adds a new resource kind to the Kubernetes API. Tekton Pipelines adds several, and two of them come back on almost every page:

| Object | What it is |
| --- | --- |
| `Task` | A reusable list of steps, with parameters and results. It does nothing on its own |
| `TaskRun` | One execution of a `Task`. Tekton creates one pod for it, with one container per step |

A **step** is one container in the pod of a `TaskRun`. A **parameter** is a named input value, and a **result** is a short named output value. The **tekton-pipelines-controller** is the program in the cluster that turns each `TaskRun` into a pod, and **`tkn`** is the command-line tool you use to start and inspect runs.

## The example setup in your playground

Every playground and lab runs on a small `kind` cluster with Tekton Pipelines installed, except where installing Tekton is the lesson. Your Tasks and TaskRuns live in the namespace `starfleet`. The example Tasks have short names, such as `hello`, `preflight` or `deploy-check`, and their parameters take crew names such as `bridge`, `scout`, `shuttle` and `probe`. The steps use the small `busybox` image, so every run is quick.

Many labs start with something broken on purpose: a TaskRun that fails, a Deployment that is scaled down, a default that someone changed. That is the material, not a fault in the course.

## How the course is laid out

The course has three sections. It starts with how Tekton runs a Task, then installs and configures Tekton itself, and ends with the command-line tool you use every day.

| Section | What it covers |
| --- | --- |
| 010 | Tekton Architecture And The Execution Model |
| 020 | Install Tekton Pipelines And The Dashboard |
| 030 | Run And Inspect Work With The tkn CLI |

Each section has one or more **modules**, and each module teaches one skill. A module brings together four kinds of material:

| What | What it is for | Graded? |
| --- | --- | --- |
| **Reading** | A short landing page, a few chapters that teach one idea each, and a summary | No |
| **Playground** | A small cluster on your own machine, to try everything you read | No |
| **Lab** | A cluster in a starting state, a task, and a grader that checks your work | Yes |
| **Capstone** | The last lab in a section, with several faults at once | Yes |

The best order is simple: read the chapters with the playground open next to them, take each lab when a chapter sends you to it, and finish each section with its capstone. The next part of this page explains how a module's pages guide you through that order.

## How to read a page

A module starts with a **landing page**. It says what the module teaches, what you should know first, and the order of its chapters. At the bottom of the landing page you start the module's playground, and you keep it running while you read.

The chapters (the parts of a module) read like the chapters of a technical book. Each one opens with the problem it solves, explains one idea in connected paragraphs, and closes with what you now know. The hands-on steps sit right in the text: a sentence or two on what to run and why, the command, and then what the result shows. Run each step in your playground as you reach it. You learn more from one real result than from a page of text.

Every chapter ends with a box of common pitfalls, the mistakes people make most often with what the chapter taught, and how to spot them. Now and then a page also has a tip box with a habit or shortcut you can use again, well beyond that page. The two boxes look like this:

> [!TIP]
> **A tip.** A habit or shortcut you can use again, well beyond this one page.

> [!WARNING]
> **Common pitfalls.** The mistakes people make most often with what you just learned, and how to spot them. Every chapter ends with one.

When a graded lab tests what a chapter taught, that chapter ends with a **Your mission** section. It tells you what the lab asks, then gives every command you need, in order: pause the playground with `astrona stop`, start the lab with `astrona run`, and send your work for grading with `astrona submit`. Solve the lab on your own before you look at its solution. When the lab is done, remove it with `astrona destroy` and start the playground again with `astrona start`, so you can carry on reading where you left off.

The last page of every module is the **Summary**. It sums up what you learned in a few short paragraphs, organised by idea. It also ends the module's hands-on work: the Summary page removes the playground, so your machine is clean before the next module.

One rule holds on every page. Code blocks are exactly what you type. Never change a command to make it "look right". If the result is different from what the page describes, that difference is the lesson.
