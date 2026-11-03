# Solution: Wire A Trigger To A Pipeline

Work the task yourself first. Running `astrona submit -c sections/section-010/module-04/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

## Step 1: Install Triggers

```sh
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
kubectl get deployments -n tekton-pipelines
```

Wait until the Triggers Deployments are available.

## Step 2: Give the listener an account

Save the ServiceAccount and the three bindings as `trigger-rbac.yaml`, as in the reading, and apply it:

```sh
kubectl apply -f trigger-rbac.yaml
```

## Step 3: Create the binding, template and listener

Save the three objects as `triggers.yaml`, as in the reading, and apply it. The webhook of Triggers can refuse the first request while it starts; apply again after a few seconds if it does:

```sh
kubectl apply -f triggers.yaml
kubectl get eventlistener deliver-listener -n starfleet
```

## Step 4: Send the request

```sh
kubectl port-forward service/el-deliver-listener 8080 -n starfleet &
curl -X POST -H 'Content-Type: application/json' -d '{"target":"orbit"}' http://localhost:8080
tkn pipelinerun list deliver -n starfleet
```

A run whose name starts with `from-trigger-` appears and succeeds.

## Step 5: Submit

```sh
astrona submit -c sections/section-010/module-04/labs/lab-01
```
