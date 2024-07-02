```bash
gcloud container clusters create {CLUSTER_NAME} \
  --network {NETWORK_NAME} \
  --subnetwork {SUB_NETWORK_NAME} \
  --cluster-version latest \
  --machine-type n1-standard-8 \
  --num-nodes 2 \
  --zone {ZONE}
  --cluster-ipv4-cidr "10.196.10.0/22"
```

```bash
gcloud container clusters create gpss-test \
  --network default \
  --subnetwork default \
  --cluster-version latest \
  --machine-type n1-standard-8 \
  --num-nodes 2 \
  --zone us-central1-c 
  --cluster-ipv4-cidr "10.196.10.0/22"
```

```bash
gcloud container clusters delete {CLUSTER_NAME} --zone {ZONE} --quiet
```

```bash
gcloud container clusters delete gpss-test --zone us-central1-c --quiet
```