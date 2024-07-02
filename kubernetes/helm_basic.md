# helm project basic

- `templates` includes all resources you want to deploy on k8s, services, ingresses, roles, rolebindings and so on.

- `charts` includes sub-charts which have same structure with a helm project. Not necessary

- `values.yaml` is user-defined variables. Files `templates` will use the variables to be a usable yaml file for `kubectl` to apply.

```bash
myapp/
|-- Chart.yaml
|-- charts/
|-- templates/
|   |-- deployment.yaml
|   |-- _helpers.tpl
|   |-- ingress.yaml
|   |-- service.yaml
|   |-- serviceaccount.yaml
|   |-- tests/
|       |-- test-connection.yaml
|-- values.yaml
```

# Release



# Chart

# Instruction

- Deploy all resources on k8s according to templetes. 
- Create a release for helm project.
```bash
helm install [RELEASE_NAME] [HELM_PROJECT_PATH]
```

Update release. `REVISION` could be numbers just like 0, 1, 2, 3...

```bash
helm upgrade [RELEASE_NAME] [HELM_PROJECT_PATH]--version [REVISION]
```

List all release. 

```bash
helm list
```

Get history for one release

```
helm history [RELEASE_NAME]
```

Rollback to a previous revision for one release

```bash
helm rollback [RELEASE_NAME] [REVISION]
```

## Remote helm

```bash
helm repo add [REPO_NAME] [REPO_URL]
helm repo update
```