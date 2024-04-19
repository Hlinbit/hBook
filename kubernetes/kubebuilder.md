## Download the kubebuilder

```bash
# If your go version is 1.19 kubebuilder version <= 3.10
# URL: https://github.com/kubernetes-sigs/kubebuilder/releases/tag/v3.10.0
wget $URL
chmod +x kubebuilder_{OS}_{ARCH}
mv kubebuilder_{OS}_{ARCH} $PATH/kubebuilder
```


## Create an operator project

```bash
mkdir project && cd project
kubebuilder init --domain <domain> --repo <project-github-url>
```

## Create corresponding API

```bash
kubebuilder create api --group <Operater_group> --version v1 --kind <Operater_name>
```

## Change the Golang struct

## Generate CRD yaml config

```bash 
make generate
make manifests
```

## Install the CRD on Kubernetes

```bash
make install
```

## Run the operator

```bash
# apply the CRD sample on k8s
kubectl apply -f <sample_file>
make run
```