# Copia Helm Chart
This chart installs Copia's version control system on a Kubernetes cluster. Read more about [Helm](https://helm.sh/).

## Installation
```
helm repo add copiaio https://dl.copia.io/charts
helm install copia-git copiaio/git
    --version v0.1.0 \
    --namespace copia --create-namespace
```

### AWS
This installation covers installing to EKS (Elastic Kubernetes Service) on AWS.

#### Prerequisites
- [Elastic Kubernetes Service](https://aws.amazon.com/eks/) cluster with available EC2 worker nodes
- [Elastic Bean Stalk Container Storage Interface](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) installed to leverage EBS volume storage

#### Compute Resourcing
##### OS
As Copia has performant persistent storage needs, Kubernetes must be run on EC2 (rather than Fargate). Any supported Linux host OS is
acceptable. [EKS Optimized Amazon Linux](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html) is commonly used
and is what Copia recommends.

##### Placement
The Copia Git application is installed as a [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/), and
must be co-located in the same availability zone as the volume where git data is stored. In a typical production EKS configuration, there is at least one node each in a minimum of three availability zones. If you are running fewer nodes, availability zone placement may be a concern. Consequently, ensure that a schedulable node is present in the same availability zone as the volume.

##### Resourcing
You can configure the memory and CPU resources allocated to the Copia application pod. It may be difficult to determine correct resourcing until under normal load, so it is recommended to allow unbounded resource allocation at first, by not setting these values. However, if you would like to set constraints, you may do so in your `values.yaml` file as follows:
```
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

#### Networking

##### Between Application and Database
Ideally, the database is running in a private subnet capable of access from pods running on the EKS cluster. Ensure that the database accepts incoming connections on the relevant port (postgres: `5432`, mysql: `3306`) from the security group ID associated with the EKS host nodes.

##### Between Application and Clients
A service is created for the Copia application that exposes an HTTP web service on port `3000`. 

#### Persistent Storage

#### SQL Database
