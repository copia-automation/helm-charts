# Copia Helm Chart

This chart installs Copia's version control system on a Kubernetes cluster. Read more about [Helm](https://helm.sh/).

## Working on this repo

Run for repo setup:

```
./bin/setup.sh
```

## Examples

### Example Azure Installation

#### Create a Custom Persistent Volume Class

Data is stored on a persistent volume hosted on an Azure disk. This Helm chart can create the volume, but you must supply it with an appropriate persistent volume class. Create the following Kubernetes resource:

**azure-volume-class.yaml**

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: azuredisk-csi
  namespace: copia
provisioner: disk.csi.azure.com
parameters:
  skuname: StandardSSD_LRS
allowVolumeExpansion: true
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```

To apply, run:

```
kubectl apply -f azure-volume-class.yaml
```

You can read more about persistent volume classes on Azure in Microsoft's [documentation](https://docs.microsoft.com/en-us/azure/aks/azure-disk-csi#dynamically-create-azure-disk-pvs-by-using-the-built-in-storage-classes).

#### Create a `values.yaml` file

Configuration of the Helm chart can be done in a custom configuration file. Default values are located in [values.yaml](./values.yaml). This example will deploy to an AKS cluster:

**values.yaml**

```
service:
  http:
    type: LoadBalancer
    port: 3000
    clusterIP: None
    #loadBalancerIP:
    #nodePort:
    #externalTrafficPolicy:
    #externalIPs:
    loadBalancerSourceRanges: []
    annotations:
persistence:
  enabled: true
  existingClaim:
  size: 600Gi
  accessModes:
    - ReadWriteOnce
  labels: {}
  annotations: {}
  storageClass: azuredisk-csi
```

## Install the Helm chart

If you have already installed Helm, run the following:

```
helm repo add copia-automation https://copia-automation.github.io/helm-charts
helm install my-copia copia-automation/copia \
  -f values.yaml \
  -n copia \
  --create-namespace
```

You should see a new pod appear by running `kubectl get pods -n copia`,

```
NAME         READY   STATUS    RESTARTS   AGE
my-copia-0   1/1     Running   0          2m30s
```

### Example AWS Installation

This installation covers installing to EKS (Elastic Kubernetes Service) on AWS.

#### Prerequisites

- [Elastic Kubernetes Service](https://aws.amazon.com/eks/) cluster with available EC2 worker nodes
- [Elastic Block Store Container Storage Interface](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) installed to leverage EBS volume storage

#### Compute Resourcing

##### OS

As Copia has performant persistent storage needs, Kubernetes must be run on EC2 (rather than Fargate). Any supported Linux host OS is
acceptable. [EKS Optimized Amazon Linux](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html) is commonly used
and is what Copia recommends.

##### Placement

The Copia Git application is installed as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/), and
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

Copia requires a Postgres database for the application to function properly.

## Troubleshooting

### Install Troubleshoot.sh Packages

The Copia helm chart leverages [troubleshoot.sh](https://troubleshoot.sh/) to perform pre-flight checks and generate support bundles.

Pre-Flights and Support Bundles are installed with [krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/):

```
kubectl krew install preflight
kubectl krew install support-bundle
```

:warning: **Note:** Pre-flights will check the connectivity to the Database from the client running the operation.
It is recommended that you connect to the DB network if it is behind a VPN or permit your local client network access
to the database endpoint in order to avoid potential false failure.

### Run Pre-Flight Checks

Running Pre-Flight checks on the Copia chart to validate the target deployment environment can be completed by running
the following command: 

`helm template copia --values values.yaml | kubectl preflight -`

### Generating Support Bundles

Generating a support bundle for the Copia chart can be completed by running the following command: 

`kubectl support-bundle --load-cluster-specs --namespace copia`

The output of the support bundle command will be a `tar.gz` file that can be reviewed before sending to Copia for support.
