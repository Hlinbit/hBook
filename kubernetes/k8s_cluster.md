
# Install container runtime

[Container runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker)

[Instruction for containerd](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)


```bash
# config containerd
sudo vim /etc/containerd/config.toml

sudo systemctl restart containerd

# dump containerd config, check if the modification takes effect
containerd config dump

sudo yum install bridge-utils
sudo modprobe br_netfilter

sudo vim /etc/sysctl.conf
# net.bridge.bridge-nf-call-iptables = 1
# net.ipv4.ip_forward = 1
sudo sysctl -p

sudo kubeadm init --config kubeinit.yml

# if init failed run:
sudo kubeadm reset
```

/etc/containerd/config.toml:

```toml
version = 2
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9"
```

kubeinit.yml:

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.117.190.117 # Replaced by external IP
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: Never
  name: mdw  # Replaced by local hostname
  taints: null
---
apiServer:
  timeoutForControlPlane: 1m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers # Require to be replaced by local mirror
kind: ClusterConfiguration
kubernetesVersion: 1.27.0
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
scheduler: {}
```

# Install calico

```bash
wget https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f calico.yaml  --namespace=kube-system
kubectl get pods --namespace=kube-system
```