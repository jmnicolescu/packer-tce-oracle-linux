#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Deploy a Management Cluster to Docker 
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# NOTE: If the Docker host machine is rebooted, the cluster will need 
#       to be re-created.
#
# Documentation:
# https://tanzucommunityedition.io/docs/latest/docker-install-mgmt/
# 
# For help in troubleshooting TCE issues go to:
# https://github.com/vmware-tanzu/tanzu-framework/issues
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 42-tce-docker-deploy-management.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

echo "Pre-req check, increase connection tracking table size."
sudo sysctl -w net.netfilter.nf_conntrack_max=524288

echo "Pre-req check, ensure bootstrap machine has ipv4 and ipv6 forwarding enabled."
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -w net.ipv4.ip_forward=1

echo "Create the management cluster"
tanzu management-cluster create -i docker --name ${MGMT_CLUSTER_NAME} --verbose 10 --plan dev --ceip-participation=false --timeout 2h

echo "Sleeping 10 seconds ..."
sleep 10

# If Management cluster cration fails during the bootstrapping process
# export KUBECONFIG=`ls ${HOME}/.kube-tkg/tmp/config*`

# If Management cluster completes successfully
# Management cluster kubeconfig is saved to ${HOME}/.kube/config

# Check management cluster details
tanzu management-cluster get

# Capture the management cluster’s kubeconfig 
export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
tanzu management-cluster kubeconfig get --admin

echo "Setting kubectl context to the management cluster."
kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
kubectl get nodes -A

END_POINT=`cat ${HOME}/.kube/config-${MGMT_CLUSTER_NAME} | grep server | awk '{print $2}'`
echo "  "
echo "End point check for ${END_POINT}"
curl --insecure ${END_POINT}

echo "List all available clusters ..."
tanzu cluster list --include-management-cluster

cat << EOF

#----------------------------------------------------------------------------
# To access the management cluster [ ${MGMT_CLUSTER_NAME} ] use:
#
# export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
#
# kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
# kubectl config current-context
#----------------------------------------------------------------------------

EOF

echo "Done 42-tce-docker-deploy-management.sh"