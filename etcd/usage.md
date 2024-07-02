# install

```bash
ETCD_VER=v3.4.22

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

/tmp/etcd-download-test/etcd --version
/tmp/etcd-download-test/etcdctl version
```

```bash
# start a local etcd server
/tmp/etcd-download-test/etcd

# write,read to etcd
/tmp/etcd-download-test/etcdctl --endpoints=localhost:2379 put foo bar
/tmp/etcd-download-test/etcdctl --endpoints=localhost:2379 get foo
```

[How to Set Up a Demo etcd Cluster](https://etcd.io/docs/v3.5/tutorials/how-to-setup-cluster/)

# Put & Get value

```bash
# Multiple Endpoints
ENDPOINTS=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379
# One Endpoint
ENDPOINTS=localhost:2379
/tmp/etcd-download-test/etcdctl --endpoints=$ENDPOINTS put web1 value1
/tmp/etcd-download-test/etcdctl --endpoints=$ENDPOINTS put web2 value2
/tmp/etcd-download-test/etcdctl --endpoints=$ENDPOINTS put web3 value3

/tmp/etcd-download-test/etcdctl --endpoints=$ENDPOINTS get web --prefix
```

# Delete key

[Tutorial Link](https://etcd.io/docs/v3.5/tutorials/how-to-delete-keys/)

```bash 
/tmp/etcd-download-test/etcdctl --endpoints=$ENDPOINTS put key myvalue
/tmp/etcd-download-test/etcdctl --endpoints=$ENDPOINTS del key

/tmp/etcd-download-test/etcdctl --endpoints=$ENDPOINTS put k1 value1
/tmp/etcd-download-test/etcdctl --endpoints=$ENDPOINTS put k2 value2
/tmp/etcd-download-test/etcdctl --endpoints=$ENDPOINTS del k --prefix
```

# Make multiple writes in a transaction

```bash
# If value("user1") = "bad", then etcd delete the key 'user1'. Otherwise, set key 'user1' with the value 'good'

# You can define any number of valid operations in 'success requests' and 'failure requests'。

etcdctl --endpoints=$ENDPOINTS put user1 bad
etcdctl --endpoints=$ENDPOINTS txn --interactive

compares:
value("user1") = "bad"

success requests (get, put, delete):
del user1

failure requests (get, put, delete):
put user1 good
```

# Watch keys

```bash
# Terminal1
etcdctl --endpoints=$ENDPOINTS watch stock --prefix
# PUT
# stock1
# 10
# PUT
# stock2
# 20
```

```bash
# Terminal2
etcdctl --endpoints=$ENDPOINTS put stock1 10
etcdctl --endpoints=$ENDPOINTS put stock2 20
```

# Lease in etcd 

In etcd, a lease is a mechanism that allows you to associate a TTL (Time-To-Live) with keys. A lease is a contract that guarantees that a key will be deleted after a specified period of time. This period of time is set when the lease is granted and is measured in seconds.

When a lease expires, all keys associated with it are automatically deleted. If the lease is refreshed before it expires, the lease lifetime is extended according to the TTL.

Leases are useful for a number of use cases:
- Service Discovery
  - Leases can be used in the service discovery mechanism. It allows clients to discover only the services that are currently running.
- Distributed Locks
  - A service can acquire a lock by associating a key with a lease. If the service that holds the lock crashes and stops refreshing the lease, the lock will be automatically released when the lease expires. 
- Caching
  - Leases can be used to implement caches with automatic expiration of entries. You can store cache entries in etcd and associate them with leases. When a cache entry is no longer refreshed, it will be automatically removed from etcd when the lease expires.

```bash
etcdctl --endpoints=$ENDPOINTS lease grant 300
# lease 2be7547fbc6a5afa granted with TTL(300s)

etcdctl --endpoints=$ENDPOINTS put sample value --lease=2be7547fbc6a5afa
etcdctl --endpoints=$ENDPOINTS get sample

etcdctl --endpoints=$ENDPOINTS lease keep-alive 2be7547fbc6a5afa
etcdctl --endpoints=$ENDPOINTS lease revoke 2be7547fbc6a5afa
# or after 300 seconds
etcdctl --endpoints=$ENDPOINTS get sample
```

#  Create locks
```bash
etcdctl --endpoints=$ENDPOINTS lock mutex1

# another client with the same name blocks
etcdctl --endpoints=$ENDPOINTS lock mutex1
```

# Election in etcd

```bash
etcdctl --endpoints=$ENDPOINTS elect <election_name> <candidate name>

# another client with the same name blocks
etcdctl --endpoints=$ENDPOINTS elect <election_name> <candidate name>
```

# Check health in Cluster

```bash
etcdctl --write-out=table --endpoints=$ENDPOINTS endpoint status
etcdctl --endpoints=$ENDPOINTS endpoint health
```

# Start a etcd to server internally and externally
etcd --data-dir /tmp/etcd/logs  --listen-client-urls http://0.0.0.0:2379 --advertise-client-urls http://{HOSTNAME}:2379