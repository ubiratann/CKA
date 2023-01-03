## Cluster

I choosed [GCP](https://cloud.google.com/) to provisioning hosts using [GCE (Google Compute Engine)](https://cloud.google.com/compute) to create and configure my own virtual machines and setup a Kubernetes cluster, as an alternative  if you dont wanna/need to know how to setup an Kubernetes cluster, you can use [GKE (Google Kubernetes Cluster)](https://cloud.google.com/kubernetes-engine)

### Terraform

Under tis folder you can find the file `gce.tf`, that creates the virtual machines in GCP, **ATENTION**, you will need to configure the required variables to(see [variables.tf](./variables.tf) to understand which values you need to set).
