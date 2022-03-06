
### Tanzu Community Edition - An automated deployment to VMware vSphere or Docker

### Build Platform - Oracle Linux R7

#### Summary

Create a custom environment that pre-bundles all required dependencies to automate the deployment of Tanzu Community Edition clusters running on either VMware vSphere or Docker.

There two steps involved in deploying Tanzu Community Edition

- Step 1. Deploy a custom Oracle Linux VM using Packer to a target environment of choice. 
          Choices include Vmware Fusion, Oracle VirtualBox, VMware ESXi or VMware vCenter.

- Step 2. Login to the custom Linux VM and deploy Tanzu Community Edition clusters.


#### Features:

Tanzu Community Edition deployment options:

- Deployment #1 - TCE Deployment to Docker
    - Deploy TCE Management Cluster to Docker as the target infrastructure provider 
    - Deploy TCE Workload Cluster

- Deployment #2 - TCE Deployment to vSphere 
    - Deploy TCE Management Cluster to vSphere as the target infrastructure provider 
    - Deploy TCE Workload Cluster

- Deployment #3 - TCE Deployment to vSphere while using NSX Advanced Load Balancer (NSX ALB)
    - Deploy TCE Management Cluster to vSphere as the target infrastructure provider
    - Deploy TCE Workload Cluster

- Deploy sample demo applications including Metallb Load Balancer, Fluent Bit and Kubernetes Dashboard.
- Easily access and debug TCE Clusters using Octant


#### References:

- TCE documentation
    https://tanzucommunityedition.io/docs/latest/
    
- TCE troubleshooting pages:
    https://github.com/vmware-tanzu/tanzu-framework/issues


#### Tanzu Community Edition component versions:


1. Tanzu Community Edition    v0.10.0-rc.2
2. kubectl                    v1.21.2
3. Kubernetes Node OS OVA     photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova


#### Directory structure:

```
[packer-tce-oracle-linux]
  │ 
  ├── http_directory                                        <-- kickstart file location
  │   └── oracle-linux
  │       └── ol7-kickstart.cfg
  ├── iso                                                   <-- Oracle Linux ISO file
  │   └── OracleLinux-R7-U9-Server-x86_64-dvd.iso
  ├── ova                                                   <-- OVA files location
  │   ├── controller-21.1.2-9124.ova 
  │   ├── photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova
  │ 
  └── scripts                                               <-- custom install scripts
```

#### Software Requirements:

1. ISO: OracleLinux-R7-U9-Server-x86_64-dvd.iso
    - [Download Oracle Linux R7 Installation Media](https://yum.oracle.com/ISOS/OracleLinux/OL7/u9/x86_64/OracleLinux-R7-U9-Server-x86_64-dvd.iso)
    - Copy OracleLinux-R7-U9-Server-x86_64-dvd.iso to the iso directory.

2. OVA: photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova
    - [Download Kubernetes node OS OVA](https://customerconnect.vmware.com/downloads/get-download?downloadGroup=TCE-090)
    - Copy photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova to the ova directory


## 1. Building the custom Linux VM 

Configuration file used for building the custom Linux VM: `ol7.pkrvars.hcl`

Before initiating the build you'll need to set Packer build environment:

The following environment variables are required by the Packer build script:

  1. PKR_VAR_vcenter_hostname       <-- vCenter host name
  2. PKR_VAR_vcenter_username       <-- vCenter user
  3. PKR_VAR_vcenter_password       <-- vCenter password
  4. PKR_VAR_vm_access_username     <-- user to SSH to the custom VM
  5. PKR_VAR_vm_access_password     <-- password for the SSH user


We'll manage all the above environment variables with GPG and PASS.
PASS is the standard unix password manager. Please refer to [Manage Passwords With GPG and PASS](README-PASS.md) for addition info about setting up PASS.

1. Insert the variables in the password store

  - pass insert provider_vcenter_hostname
  - pass insert provider_vsphere_user
  - pass insert provider_vsphere_password
  - pass insert vm_access_username
  - pass insert vm_access_password

2. Read the secrets from pass and set them as environment variables

  - export PKR_VAR_vcenter_hostname=$(pass provider_vcenter_hostname)
  - export PKR_VAR_vcenter_username=$(pass provider_vcenter_username)
  - export PKR_VAR_vcenter_password=$(pass provider_vcenter_password)
  - export PKR_VAR_vm_access_username=$(pass vm_access_username)
  - export PKR_VAR_vm_access_password=$(pass vm_access_password)

In addition, we'll need to edit Packer Variable definition file [ol7.pkrvars.hcl](ol7.pkrvars.hcl)  to set the rest of vCenter variables required for the build.


#### VM Deployment Option #1 - Deployment to VMware Fusion

To deploy the custom Oracle Linux R7 VM to VMware Fusion run the following command:

```bash
packer build -var-file=ol7.pkrvars.hcl ol7-fusion.pkr.hcl
```

#### VM Deployment Option #2 - Deployment to an ESXi host

To allow packer to work with the ESXi host - enable “Guest IP Hack”

```bash
  esxcli system settings advanced set -o /Net/GuestIPHack -i 1
```

To deploy the custom Oracle Linux R7 VM to an ESXi host run the following command:

```bash
  packer build -var-file=ol7.pkrvars.hcl ol7-esxi.pkr.hcl
```

#### VM Deployment Option #3 - Deployment to VMware vSphere

To deploy the custom Oracle Linux R7 VM to VMware vSphere run the following command:

```bash
packer build -var-file=ol7.pkrvars.hcl ol7-vcenter.pkr.hcl
```

#### VM Deployment Option #4 - Deployment to Oracle VirtualBox

To deploy the custom Oracle Linux R7 VirtualBox VM in the OVF format run the following command:

```bash
packer build -var-file=ol7.pkrvars.hcl ol7-virtualbox.pkr.hcl
```

## 2. TCE installation and cluster configuration

Configuration file used for TCE deployment: `scripts/00-tce-build-variables.sh`

Optional: For the custom Linux VM, update /etc/hosts file with the IP address obtained from DHCP server OR set a static IP.

```bash
# Update host entry in the /etc/hosts file using the current DHCP assigned IP
 sudo ./30-update-etc-hosts.sh

 OR

 # Set a static IP for the custom Linux VM
 sudo ./30-configure-with-static-ip.sh
```

Setting the TCE build environment:

With the exception of vCenter credentials, all TCE Build Variable are set in 00-tce-build-variables.sh
Please review and update [Tanzu Community Edition - Build Variable Definition](scripts/00-tce-build-variables.sh) file.

#### TCE Deployment option #1 - TCE deployment to Docker

Login to the Linux built VM as user tce, chnage directory to scripts and run the following scripts:
  
```bash
cd scripts

# Update host entry in the /etc/hosts file using the current DHCP assigned IP
 sudo ./30-update-etc-hosts.sh

# Reset Environment and Install Tanzu Community Edition
./33-tce-install.sh

# Run the following script to create the TCE Management Cluster 
./42-tce-docker-deploy-management.sh

# Run the following script to create the TCE Workload Cluster 
./43-tce-docker-deploy-workload.sh

# Deploy Metallb Load Balancer
./70-demo-deploy-metallb.sh

# Deploy sample demo applications including Fluent Bit.
./71-demo-deploy-web-apps.sh

```

#### TCE Deployment option #2 - TCE deployment to VMware vSphere

Login to the Linux VM as user tce, chnage directory to scripts and run the following scripts:

```bash  
cd scripts

# Insert the vCenter host name and user credentials into the password store
pass insert provider_vcenter_hostname
pass insert provider_vcenter_username
pass insert provider_vcenter_password

# Update host entry in the /etc/hosts file using the current DHCP assigned IP
sudo ./30-update-etc-hosts.sh

# Reset Environment and Install Tanzu Community Edition
./33-tce-install.sh

# vSphere Requirerments, Deploy Kubernetes node OS VM 
./50-vsphere-deploy-k8s-ova

# Deploy a Management Cluster to vSphere 
./52-vsphere-deploy-management.sh

# Deploy a Workload Cluster to vSphere
./53-vsphere-deploy-workload.sh

# Deploy Metallb Load Balancer
./70-demo-deploy-metallb.sh

# Deploy demo application: assembly-webapp
./71-demo-deploy-web-apps.sh

# Install Fluent Bit using TCE Tanzu Packages
./72-demo-tce-tanzu-packages.sh

# Deploy Kubernetes Dashboard
./73-demo-deploy-k8s-dashboard.sh

```

#### TCE Depolyment option #3 - TCE deployment to VMware vSphere using NSX Advanced Load Balancer

Login to the Linux VM as user tce, chnage directory to scripts and run the following scripts:
  
```bash  
cd scripts

# Insert the vCenter host name and user credentials into the password store
pass insert provider_vcenter_hostname
pass insert provider_vcenter_username
pass insert provider_vcenter_password

# Update host entry in the /etc/hosts file using the current DHCP assigned IP
sudo ./30-update-etc-hosts.sh

# Reset Environment and Install Tanzu Community Edition
./33-tce-install.sh

# vSphere Requirerments, Deploy Kubernetes node OS VM 
./50-vsphere-deploy-k8s-ova

# Deploy NSX Advanced Load Balancer OVA
./60-nsx-alb-deploy-avi-ova.sh

# Configure NSX Advanced Load Balancer 
# Follow [README-NSX-ALB.md guide](README-NSX-ALB.md) to configure NSX ALB

# Deploy a Management Cluster to vSphere using NSX ALB
./62-nsx-alb-deploy-management.sh

# Deploy a Workload Cluster to vSphere using NSX ALB
./63-nsx-alb-deploy-workload.sh

# Deploy demo application: assembly-webapp
./71-demo-deploy-web-apps.sh

# Install Fluent Bit using TCE Tanzu Packages
./72-demo-tce-tanzu-packages.sh

# Deploy Kubernetes Dashboard
./73-demo-deploy-k8s-dashboard.sh

```

## 3. Accessing Tanzu Community Edition clusters from the custom Linux VM

#### To access TCE management cluster, login as tce user and run:

```bash
export MGMT_CLUSTER_NAME="tce-management"
export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
kubectl get nodes -A
```
The management cluster kubeconfig file `${HOME}/.kube/config-${MGMT_CLUSTER_NAME}` is created during the install.

If you need to recapture the management cluster’s kubeconfig, execute the following commands:

```bash
export MGMT_CLUSTER_NAME="tce-management"
export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
tanzu management-cluster kubeconfig get --admin
kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
kubectl get nodes -A
```

#### To access TCE workload cluster, login as tce user and run:

```bash 
  export WKLD_CLUSTER_NAME="tce-workload"
  export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
  tanzu cluster kubeconfig get ${WKLD_CLUSTER_NAME} --admin
  kubectl config use-context ${WKLD_CLUSTER_NAME}-admin@${WKLD_CLUSTER_NAME}
  kubectl get nodes -A
```
The workload cluster kubeconfig file `${HOME}/.kube/config-${WKLD_CLUSTER_NAME}` is created during the install.

If you need to recapture the workload cluster’s kubeconfig, execute the following commands:

```bash 
  export WKLD_CLUSTER_NAME="tce-workload"
  tanzu cluster kubeconfig get ${WKLD_CLUSTER_NAME} --admin
  kubectl config use-context ${WKLD_CLUSTER_NAME}-admin@${WKLD_CLUSTER_NAME}
  kubectl get nodes -A
  
  or just:
  export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
  kubectl get nodes -A
```

## 4. Troubleshooting tips:

The bootstrap cluster kubeconfig is located in `${HOME}/.kube-tkg/tmp` directory.
To check the progress of the install run:

```bash 
export KUBECONFIG=`ls ${HOME}/.kube-tkg/tmp/config_*`
kubectl get pods,deployments -A
kubectl get kubeadmcontrolplane,machine,machinedeployment -A
kubectl get events -A
```

To recover from a failed deployment, wipe all previous TCE configurations and reset the environment execute the following commands:

```bash
# Docker Cleanup - Stop all existing containers, remove containers, prune all existing volumes
./34-docker-cleanup.sh

# Wipe all previous TCE configurations, Reset Environment and Install Tanzu Community Edition
./33-tce-install.sh
```