#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Create Standalone Docker Cluster
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# NOTE: If the Docker host machine is rebooted, the cluster will need 
#       to be re-created.
#
# Warning - Standalone clusters will be deprecated in a future release of Tanzu Community Edition
# Checkout the proposal for the standalone cluster replacement:
# https://github.com/vmware-tanzu/community-edition/issues/2266
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Standalone clusters are deprecated and will be removed in a future release of Tanzu Community Edition
# For a minimal, single node cluster, 'unmanaged-cluster' replaces 'standalone-clusters'
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 44-tce-docker-deploy-standalone.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

echo "Create unmanaged cluster - ${MGMT_CLUSTER_NAME}"
CLUSTER_PLAN=dev tanzu unmanaged-cluster create ${MGMT_CLUSTER_NAME} --verbose 10

echo "Sleeping 10 seconds ..."
sleep 10

# If unmanaged cluster cration fails during the bootstrapping process
# export KUBECONFIG=`ls ${HOME}/.kube-tkg/tmp/config*`

cp ${HOME}/.config/tanzu/tkg/unmanaged/${MGMT_CLUSTER_NAME}/kube.conf ${HOME}/.kube/config
export KUBECONFIG=${HOME}/.kube/config

echo "List all available clusters ..."
tanzu unmanaged-cluster list

cat << EOF

#----------------------------------------------------------------------------
# To access the unmanaged cluster [ ${MGMT_CLUSTER_NAME} ] use:
#
# export KUBECONFIG=${HOME}/.kube/config
#----------------------------------------------------------------------------

EOF

echo "Done 44-tce-docker-deploy-standalone.sh"