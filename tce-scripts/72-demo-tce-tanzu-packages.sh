#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Install Fluent Bit using TCE Tanzu Packages. 
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# Reference:
# https://cormachogan.com/2021/10/05/getting-started-with-carvel-and-tanzu-packages-in-tce/
#--------------------------------------------------------------------------

source ${HOME}/scripts/00-tce-build-variables.sh

if [ ! -f ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} ]; then
    echo "File: ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} missing ..."
    echo "Exiting ..."
    exit 1
fi

export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}

REPO_NAME="tce-main-latest"
REPO_URL="projects.registry.vmware.com/tce/main:latest"
REPO_NAMESPACE="tanzu-package-repo-global"

echo "Install repository to the [ ${REPO_NAMESPACE} ] namespace"
echo "Adding TCE package [ ${REPO_NAME} ] repository"

tanzu package repository add ${REPO_NAME} --namespace ${REPO_NAMESPACE} --url ${REPO_URL}
tanzu package repository get ${REPO_NAME} -o json | jq -r '.[0].status | select (. != null)'

echo "Sleeping 60 seconds ... wait for packages to be available"
sleep 60
tanzu package repository list -A

echo "#--------------------------------------------------------------"
echo "TCE package repository -> Checking available package list ..."
echo "#--------------------------------------------------------------"
tanzu package available list

echo "#--------------------------------------------------------------"
echo "TCE package repository -> Checking installed package list ..."
echo "#--------------------------------------------------------------"
tanzu package installed list

#--------------------------------------------------------------------------
# Demo App: Fluent Bit
#--------------------------------------------------------------------------

DEMO_FLUENT_BIT_PACKAGE="fluent-bit.community.tanzu.vmware.com"

echo "Demo App: Installing fluent-bit -- Fluent Bit is a fast Log Processor and Forwarder"
tanzu package available list ${DEMO_FLUENT_BIT_PACKAGE}
fluentbit_version=$(tanzu package available list ${DEMO_FLUENT_BIT_PACKAGE} -o json | jq -r '.[0].version | select(. !=null)')
tanzu package install fluent-bit --package-name ${DEMO_FLUENT_BIT_PACKAGE} --version "${fluentbit_version}"
tanzu package installed list
