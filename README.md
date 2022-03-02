
## Automate Tanzu Community Edition deployment to VMware vSphere or Docker using a custom VM running Oracle Linux R7


#### Build features:

```
   Linux VM deployment options:
   Multiple deployment options: Vmware Fusion, Oracle VirtualBox, VMware ESXi, VMware vCenter.
   Build and deploy a custom Oracle Linux R7 VM to a target environment of choice.

   Tanzu Community Edition deployment options:
   Deploy a Management Cluster to Docker as the target infrastructure provider 
   Deploy a Workload Cluster

   Deploy a Management Cluster to vSphere as the target infrastructure provider 
   Deploy a Workload Cluster

   Deploy a Management Cluster to vSphere as the target infrastructure provider using NSX Advanced Load Balancer (NSX ALB)
   Deploy a Workload Cluster

   Deploy Demo Apps, Fluent Bit and Kubernetes Dashboard

   TCE settings for deployment to Docker:
   Management Cluster Settings - Development - A management cluster with a single control plane node.
   Workload Cluster Settings   - Development - A workload cluster with a single worker node.

   TCE settings for deployment to VMware vSphere:
   Management Cluster Settings - Development - A management cluster with a single control plane node.
   Workload Cluster Settings   - Production - A workload cluster with three worker nodes.

```

#### References:

```
    TCE documentation
    https://tanzucommunityedition.io/docs/latest/
    
    TCE troubleshooting pages:
    https://github.com/vmware-tanzu/tanzu-framework/issues
```

#### Tanzu Community Edition component versions used in this project

```
   1. Tanzu Community Edition    v0.10.0-rc.2
   2. kubectl                    v1.21.2
   3. Kubernetes Node OS OVA     photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova
```

#### Software Requirements

```
   1. ISO: OracleLinux-R7-U9-Server-x86_64-dvd.iso
      Download Oracle Linux R7 Installation Media from https://yum.oracle.com/oracle-linux-isos.html
      https://yum.oracle.com/ISOS/OracleLinux/OL7/u9/x86_64/OracleLinux-R7-U9-Server-x86_64-dvd.iso
      Copy OracleLinux-R7-U9-Server-x86_64-dvd.iso to the iso directory.

   2. OVA: photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova
      Download Kubernetes node OS OVA from VMware Customer Connect
      https://customerconnect.vmware.com/downloads/get-download?downloadGroup=TCE-090
      Copy photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova to the ova directory
```

#### Directory structure

```

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

## 1. Building the Linux VM 

```
  Setting the Packer build environment:

  # Insert the vCenter host name in the password store
  pass insert provider_vcenter_hostname
  # Insert the vCenter access user in the password store
  pass insert provider_vsphere_user
  # Insert the password vCenter user in the password store
  pass insert provider_vsphere_password
  # Insert the VM ssh user access in the password store
  pass insert vm_access_username
  # Insert the passord for the VM ssh user access in the password store
  pass insert vm_access_password

  # Read the secrets from pass and set them as environment variables

  export PKR_VAR_vcenter_hostname=$(pass provider_vcenter_hostname)
  export PKR_VAR_vcenter_username=$(pass provider_vcenter_username)
  export PKR_VAR_vcenter_password=$(pass provider_vcenter_password)
  export PKR_VAR_vm_access_username=$(pass vm_access_username)
  export PKR_VAR_vm_access_password=$(pass vm_access_password)

```

#### VM Deployment Option #1 - Deployment to VMware Fusion

```
  # To deploy the custom Oracle Linux R7 VM to VMware Fusion run:
  packer build -var-file=ol7.pkrvars.hcl ol7-fusion.pkr.hcl
```

#### VM Deployment Option #2 - Deployment to an ESXi host

```
  # To allow packer to work with the ESXi host - enable “Guest IP Hack”
  esxcli system settings advanced set -o /Net/GuestIPHack -i 1

  # To deploy the custom Oracle Linux R7 VM to an ESXi host run:
  packer build -var-file=ol7.pkrvars.hcl ol7-esxi.pkr.hcl
```

#### VM Deployment Option #3 - Deployment to VMware vSphere

```
  # To deploy the custom Oracle Linux R7 VM to VMware vSphere run:
  packer build -var-file=ol7.pkrvars.hcl ol7-vcenter.pkr.hcl
```

#### VM Deployment Option #4 - Deployment to Oracle VirtualBox

```
  # To deploy the custom Oracle Linux R7 VirtualBox VM in the OVF format:
  packer build -var-file=ol7.pkrvars.hcl ol7-virtualbox.pkr.hcl
```

## 2. TCE installation and cluster configuration

Setting the TCE build environment:

With the exception of vCenter credentials, all TCE Build Variable are set in 00-tce-build-variables.sh
Please update 00-tce-build-variables.sh file.

#### TCE Deployment option #1 - TCE deployment to Docker

```
  login as user tce to the Linux built VM
  cd scripts

  # Update host entry in the /etc/hosts file using the current DHCP assigned IP
  sudo ./30-update-etc-hosts.sh

  # Reset Environment and Install Tanzu Community Edition
  ./33-install-tce.sh

  # Deploy a Management Cluster to Docker 
  ./42-tce-docker-deploy-management.sh

  # Deploy a Workload Cluster to Docker
  ./43-tce-docker-deploy-workload.sh

  # Deploy Metallb Load Balancer
  ./70-demo-deploy-metallb.sh

  # Deploy Demo Apps and Fluent Bit
  ./71-demo-deploy-web-apps.sh

```

#### TCE Deployment option #2 - TCE deployment to VMware vSphere

```
  login as user tce to the Linux built VM
  cd scripts
 
  # Update vSphere credentials

  # Insert the user provider_vsphere_user in the password store
  pass insert provider_vsphere_user

  # Insert the password for provider_vsphere_password in the password store
  pass insert provider_vsphere_password

  # Update host entry in the /etc/hosts file using the current DHCP assigned IP
  sudo ./30-update-etc-hosts.sh

  # Reset Environment and Install Tanzu Community Edition
  ./33-install-tce.sh

  # vSphere Requirerments, Deploy Kubernetes node OS VM 
  ./50-vsphere-deploy-k8s-ova

  # Deploy a Management Cluster to vSphere 
  ./52-vsphere-deploy-management.sh

  # Deploy a Workload Cluster to vSphere
  ./53-vsphere-deploy-workload.sh

  # Deploy Metallb Load Balancer
  ./70-demo-deploy-metallb.sh

  # Deploy Demo Apps and Fluent Bit
  ./71-demo-deploy-web-apps.sh

  # Deploy Kubernetes Dashboard
  ./72-demo-deploy-k8s-dashboard

```

#### TCE Depolyment option #3 - TCE deployment to VMware vSphere using NSX Advanced Load Balancer

```
  login as user tce
  cd scripts
 
  # Update vSphere credentials

  # Insert the user provider_vsphere_user in the password store
  pass insert provider_vsphere_user

  # Insert the password for provider_vsphere_password in the password store
  pass insert provider_vsphere_password

  # Update host entry in the /etc/hosts file using the current DHCP assigned IP
  sudo ./30-update-etc-hosts.sh

  # Reset Environment and Install Tanzu Community Edition
  ./33-install-tce.sh

  # vSphere Requirerments, Deploy Kubernetes node OS VM 
  ./50-vsphere-deploy-k8s-ova

  # Deploy NSX ALB OVA
  ./60-nsx-alb-deploy-avi-ova.sh

  # Configure NSX ALB - Follow README-NSX-ALB.md guide

  # Deploy a Management Cluster to vSphere using NSX ALB
  ./62-nsx-alb-deploy-management.sh

  # Deploy a Workload Cluster to vSphere using NSX ALB
  ./63-nsx-alb-deploy-workload.sh

  # Deploy Demo Apps and Fluent Bit
  ./71-demo-deploy-web-apps.sh

  # Deploy Kubernetes Dashboard
  ./72-demo-deploy-k8s-dashboard

```

## 3. Accessing the clusters

#### To access the management cluster, login as tce user and run:

```
  export MGMT_CLUSTER_NAME="tce-management"
  tanzu management-cluster kubeconfig get --admin
  kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
  kubectl get nodes -A

  or just:
  export MGMT_CLUSTER_NAME="tce-management"
  export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
  kubectl get nodes -A

  Note: ${HOME}/.kube/config-${MGMT_CLUSTER_NAME} is created during the install
```

#### To access the workload cluster, login as tce user and run:

```
  export WKLD_CLUSTER_NAME="tce-workload"
  tanzu cluster kubeconfig get ${WKLD_CLUSTER_NAME} --admin
  kubectl config use-context ${WKLD_CLUSTER_NAME}-admin@${WKLD_CLUSTER_NAME}
  kubectl get nodes -A
  
  or just:
  export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
  kubectl get nodes -A

  Note: ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} is created during the install
```
