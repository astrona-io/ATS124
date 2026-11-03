# Solution: Install Tekton With The Operator

Work the task yourself first. Running `astrona submit -c sections/section-020/module-03/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

## Step 1: Install the Operator

```sh
kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml
kubectl rollout status deployment/tekton-operator -n tekton-operator --timeout=300s
kubectl rollout status deployment/tekton-operator-webhook -n tekton-operator --timeout=300s
```

## Step 2: Create the TektonConfig

Save this as `tektonconfig.yaml`:

```yaml
apiVersion: operator.tekton.dev/v1alpha1
kind: TektonConfig
metadata:
  name: config
spec:
  profile: lite
  targetNamespace: tekton-pipelines
  pipeline:
    default-timeout-minutes: 30
```

Apply it:

```sh
kubectl apply -f tektonconfig.yaml
```

## Step 3: Wait for Tekton

```sh
kubectl wait --for=condition=Ready tektonconfig/config --timeout=900s
kubectl get configmap config-defaults -n tekton-pipelines -o jsonpath='{.data.default-timeout-minutes}{"\n"}'
```

The second command prints `30`.

## Step 4: Run a TaskRun

Save this as `taskrun-check.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: check-
  namespace: starfleet
spec:
  taskSpec:
    steps:
      - name: say
        image: busybox:1.37.0
        script: |
          #!/bin/sh
          echo "Installed by the Operator"
```

Create it, because `generateName` needs `create`:

```sh
kubectl create -f taskrun-check.yaml
```

## Step 5: Submit

```sh
astrona submit -c sections/section-020/module-03/labs/lab-01
```
