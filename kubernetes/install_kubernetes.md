# Update and Install Required Packages

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
```

# Disable swap

```bash
sudo swapoff -a
```

OR

```bash
sudo vim /etc/fstab
# Comment out the line containing swap
```

# install kubeadm

link[https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/]


Update the apt package index and install packages needed to use the Kubernetes apt repository

```bash
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

Download the public signing key for the Kubernetes package repositories. 

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

Add the appropriate Kubernetes apt repository.
```bash
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

```bash
sudo systemctl enable --now kubelet
```

# Start a cluster

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=<MASTER_IP>
```

Make nodes ready.
```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```