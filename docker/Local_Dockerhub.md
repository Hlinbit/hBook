
```bash
docker run -d -p 5000:5000 --name registry registry:2
```

```bash
docker tag your-image:tag localhost:5000/your-image:tag
docker push localhost:5000/your-image:tag
```

```bash
docker pull localhost:5000/your-image:tag
```

The default transfer protocol is https for opertion 'pull'. If your local registry doesn't support SSL  protocol. You can modify the following files to avoid using https protocol.

For Docker, modify /etc/docker/daemon.json:
```json
{
  "insecure-registries" : ["HOSTNAME:5000"]
}
```

For containerd (using ctr command), modify /etc/containerd/config.toml：
```bash
version: 2
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."HOSTNAME:5000"]
    endpoint = ["http://HOSTNAME:5000"]
    insecure = true
```