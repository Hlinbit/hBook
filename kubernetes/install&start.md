# download

[`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) and [`minikube`](https://minikube.sigs.k8s.io/docs/start/) are essential for build a kubernetes cluster.

Dependencies for `minikube` :
- Docker  https://cloud.tencent.com/developer/article/1701451

# Start A Cluster

[Start a cluster](https://minikube.sigs.k8s.io/docs/start/)

[Introduction for minikube](https://kubernetes.io/docs/tutorials/hello-minikube/)


# Minikube

## Start a cluster

```bash
minikube start --nodes 2 --cni calico
```

## Clean all data

```bash
minikube delete --all
```

## Check all nodes

```bash
minikube node list

minikube ssh -n [hostname]
```

## Load local docker image into minikuber docker

```bash
minikube image load [name]:[tag]
```

# kubectl

## Check resource

```bash
kubectl describe [type] [name]
# type: deployment, service, pod and so on.
```

## Debug pod

```bash
kubectl get pods -l app=[name]

# output : pod name and status

kubectl describe pod [pod-name]

# Detailed status information and error messages.
```