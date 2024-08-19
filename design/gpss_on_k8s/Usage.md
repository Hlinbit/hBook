# An operator for distributed GPSS cluster on Kubernetes

GPSS Operator is software for managing distributed GPSS clusters on the Kubernetes platform. It automates the deployment of distributed GPSS clusters on Kubernetes and supports features such as updating clusters and automatic recovery. 

In addition to the operator program, we have also defined the CRD type gpsscluster. By creating a gpsscluster, users can declaratively create distributed GPSS clusters; by updating the gpsscluster, users can update cluster configurations, such as the image version being used, resource usage limits, and more.

# Distributed GPSS Architecture on Kubernetes 

Based on the characteristics of distributed GPSS, we have designed the following distributed GPSS cluster architecture on Kubernetes:

This architecture mainly consists of the following components: the GPSS service that receives requests from GPSS clients, the Gpfdist service that receives data requests from the gpdb cluster, and the GPSS instances that provide external services.

![GPSS cluster on kubernetes internal overview](./picture/gpss_cluster_internal_overview.png)

The design considerations are as follows: 
1. It is difficult to deploy the GPDB cluster within the Kubernetes cluster. Meanwhile, external access to the Kubernetes cluster must be facilitated through network interfaces, such as services, to reach instances inside the Kubernetes cluster. Therefore, the distributed GPSS cluster on Kubernetes must use GPSS service and Gpfdist service to accept requests from GPSS clients and GPDB segments outside the cluster.
2. For GPDB, each dataflow task requires the segment to locate the corresponding GPSS instance via the URL of the gpfdist external table to successfully retrieve data. This means that each GPSS instance must create an external table according to its exposed network interface. Concurrently, GPDB should be able to access the corresponding GPSS instance through the GPSS instance's network interface to retrieve data. This means that each GPSS instance must have a corresponding Gpfdist service to receive access requests from GPDB segments.


# How to use GPSS cluster on Kubernetes 

## Preparation for Deploying a Cluster

Before using the GPSS cluster on Kubernetes, we need to perform some configuration and checks. This mainly includes two aspects:
- Grant Pod Subnet Access to GPDB
- Kubernetes Cluster Firewall Settings

### Grant Pod Subnet Access to GPDB

Because GPSS needs to operate the GPDB database via psql, we must add the following record to the pg_hba.conf file in the coordinator directory:

```
host     all       {User}       {Pod Network CIDR}    trust
```

Grant GPSS instances the ability to operate the GPDB cluster.


### Kubernetes Cluster Firewall Settings

Firewall rules are crucial in determining whether GPDB and GPSS can communicate with each other. Since deploying a GPDB cluster within a Kubernetes environment is challenging, it is almost certain that GPDB will need to access GPSS instances from outside the Kubernetes cluster. 

From the Kubernetes perspective, there are two scenarios:

- Kubernetes cluster supports LoadBalancer service type: In this case, there is almost no need to consider firewall configuration. Kubernetes will allocate an external access IP from the public IP and open network ports as configured.

- Kubernetes cluster does not support LoadBalancer service type: In this scenario, NodePort service is the only way to expose GPSS services (currently, gpsscluster only supports ClusterIP, NodePort, and LoadBalancer service types). This means that customers need to open the port range for NodePort services on the hosts running Kubernetes.

From the perspective of GPDB, we need to open the Psql access port on the Coordinator host's firewall configuration to allow access from the GPSS instances.

## Deploy the GPSS operator on Kubernetes

The GPSS operator provides a way to deploy the operator container in Kubernetes using Helm. After obtaining the Helm package, you can deploy it using  `helm install`. Users can customize the operator's image address, image pull policy, and related resource names by defining them in the `values.yaml` file of the Helm package.

Note two typical scenarios here.

### Network unavailable

When external network access is not available, we can still deploy the operator using Helm. First, download the official operator image and distribute it to the local Docker environment of the Kubernetes cluster. Then, in the `values.yaml` file of the Helm package, change the pullPolicy variable to IfNotPresent or Never. This way, the deployment image can be retrieved from the local Docker.

### Private authorization information

Some customers, for information security reasons, store images in a private repository. This means that we need to provide special authentication information to pull the images. In the values.yaml file of the Helm package, we support specifying the name of a secret containing the authentication information, allowing Kubernetes to pull images from the repository.

# Define a GPSS cluster on Kubernetes

The CRD `gpsscluster` is used to define the resource type for a GPSS cluster on Kubernetes. It contains the following fields:

- size: define the number of instances in the cluster. Its value must be greater than or equal to 0.
- image: define the GPSS image. For images from a remote repository, it is the image URL with tag. For local images, it is image name with tag.
- service: Define the types of GPSS and Gpfdist services in the cluster, including `LoadBalancer`, `ClusterIP`, and `NodePort`.
- resources: Define the resource requests and limits for each GPSS instance when it is created.
- pull_policy: The policy for pulling the GPSS image, including `Always`, `IfNotPresent`, and `Never`.
- pull_secret: The name of the secret containing the authentication information for pulling the GPSS image. 
- gpss_config: GPSS instance startup configuration in JSON format. For details, please refer to the [GPSS documentation](https://docs.vmware.com/en/VMware-Greenplum-Streaming-Server/index.html).

```yaml
apiVersion: gpss.gpdb.io/v1
kind: GpssCluster
metadata:
  name: gpfdist
  namespace: gpss-workspace-test
spec:
  size: 3
  image: us-west1-docker.pkg.dev/data-gpdb-dev2/gpss-test-images/gpss:test
  service:
    gpss: NodePort
    gpfdist: NodePort
  resources:
    limits:
      cpu: "8" 
      memory: 32Gi
    requests:
      cpu: "1"
      memory: 1Gi
  pull_policy: Always
  pull_secret: gpss-docker-key
  gpss_config: |
    {
      "ListenAddress": {
          "Host": "",
          "Port": 5000
      },
      "Gpfdist": {
          "Host": "",
          "Port": 8090
      },
      "Cluster":{
          "Id": "gpfdist",
          "Port": 5001,
          "Etcd": {
              "Endpoints": ["etcd:2379"]
          }
      }
    }
```

# Cluster Configuration in Detail

### Update or Rollback the Container Image

By changing the image field of the `GpssCluster`, we can achieve cluster updates and rollbacks.

### Change the Cluster Size

By changing the `size` field of the `GpssCluster`, we can achieve cluster scaling in and out.

### Provide Authentication Information for Pulling GPSS Image

When we need to fetch the GPSS image from a remote repository, Kubernetes needs permission to pull the image from the repository. Customers can specify a secret containing the authentication information in the `pull_secret` field of the `GpssCluster` to ensure that the operator can successfully create the GPSS cluster.

### Define the Policy to Pull the GPSS Image

The GPSS operator supports users in pulling the GPSS image from either local or remote sources. If the Kubernetes cluster cannot reach the remote image repository, you can set the `pull_policy` field to `Never`. This way, the operator will fetch the image from the Docker environment within the Kubernetes cluster to complete the cluster build.

### Define Computational Resources for the GPSS Container

`GpssCluster` supports defining the resource usage of each instance in the cluster through the resources field. The format of resources is exactly the same as the format used by Kubernetes to define resources. For more details, you can refer to the Kubernetes documentation. The default settings are: 2GB of memory and 2 CPU cores at startup. The resource limits are 16GB of memory and 8 CPU cores.

### Define Service Type of GPSS and Gpfdist

`GpssCluster` supports users in defining the types of the GPSS service and the Gpfdist service. Since it is difficult to deploy GPDB in Kubernetes, providing a service for GPDB to access GPSS instances is crucial. In the operator, we support three types of services: `LoadBalancer`, `ClusterIP`, and `NodePort`. The default service type is `LoadBalancer`, and users can define the service type according to their needs.

# Interaction between Gpsscli and the Cluster on Kubernetes

`gpsscli` is the official tool for managing data flow jobs in GPSS clusters on Kubernetes. `gpsscli` needs to access the GPSS on Kubernetes cluster through the GPSS service. This means that when using gpsscli, the user must specify `--gpss-host` as the IP or hostname of the GPSS service, and `--gpss-port` as the port exposed by the service.

Regardless of what type of service is defined, the GPSS service is named in the format "`{namespace}-{name}-gpss-service`". `{namespace}` refers to the namespace where the GpssOperator is located, and `{name}` is the user-defined name of the GpssOperator.


Therefore, you can obtain the information of the GPSS service through kubectl or the visual panel on the cloud service.