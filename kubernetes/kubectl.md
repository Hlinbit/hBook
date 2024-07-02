# Show all pods name and IP

```bash
kubectl get pods -o custom-columns=NAME:.metadata.name,IP:.status.podIP --namespace {namespace}
```

# Show all nodes name and IP
```bash
kubectl get nodes -o custom-columns="NAME:.metadata.name,INTERNAL-IP:.status.addresses[?(@.type=='InternalIP')].address,EXTERNAL-IP:.status.addresses[?(@.type=='ExternalIP')].address"
```

# Show all pods name, IP and status in a namespace

```bash
kubectl get pods -n {namespace} -o custom-columns=N
AME:.metadata.name,IP:.status.podIP,STATUS:.status.phase
```

# Edit resource by kubectl

```bash
kubectl edit {resource_type} {name} -n {namespace}
```

# Get all information of a resource 

```bash
kubectl get {resource_type} {name} -n {namespace} -o json
```

# Get log printed by pod 

```bash
# Log currently printed
kubectl logs <pod_name> -n <namespace>
# Follow the log
kubectl logs -f {pod_name} -n {namespace}
# Specify container
kubectl logs {pod_name} -c {container_name} -n {namespace}
```

# Create docker-pull secret

```bash
kubectl create secret docker-registry gpss-docker-key \
    --docker-server=https://us-west1-docker.pkg.dev \
    --docker-username=_json_key \
    --docker-password="$(cat /path/to/secret.file)" \
```

# config default namespace 
```bash
kubectl config set-context --current --namespace=<namespace>
```