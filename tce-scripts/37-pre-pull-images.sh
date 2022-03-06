#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Pre pull TCE images [ 37-pre-pull-images.sh ]
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 37-pre-pull-images.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

echo "Pre-req check, increase connection tracking table size."
sudo sysctl -w net.netfilter.nf_conntrack_max=524288

# We should really not do this, but it helps. Images' version are provided in the $TCE_VERSION BOM file.
pre_pull_array=( \
      "kindest/kindnetd:0.5.4" \ 
      "kindest/haproxy:v20210715-a6da3463" \
      "projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1" \
      "projects.registry.vmware.com/tkg/coredns:v1.8.0_vmware.5" \ 
      "projects.registry.vmware.com/tkg/kube-proxy:v1.21.2_vmware.1" \
      "projects.registry.vmware.com/tkg/antrea/antrea-debian:v0.13.3_vmware.1" \
      "rancher/local-path-provisioner:v0.0.12" \
      "projects.registry.vmware.com/tkg/cluster-api/capd-manager:v0.3.23_vmware.1" \
      "projects.registry.vmware.com/tkg/cluster-api/kubeadm-bootstrap-controller:v0.3.23_vmware.1" \
      "projects.registry.vmware.com/tkg/cluster-api/kubeadm-control-plane-controller:v0.3.23_vmware.1" \
      "projects.registry.vmware.com/tkg/cluster-api/cluster-api-controller:v0.3.23_vmware.1" \
      "projects.registry.vmware.com/tkg/cluster-api/kube-rbac-proxy:v0.8.0_vmware.1" \
      "projects.registry.vmware.com/tkg/cert-manager-cainjector:v1.1.0_vmware.1" \
      "projects.registry.vmware.com/tkg/cert-manager-webhook:v1.1.0_vmware.1" \
      )

for image in ${pre_pull_array[@]}; do
  echo "#-----------------------------------------------------------------------------------"
  echo "TCE ${TCE_VERSION}: Pre-pull $image "
  docker pull $image
  echo "#-----------------------------------------------------------------------------------"
done

echo "Done 37-pre-pull-images.sh"