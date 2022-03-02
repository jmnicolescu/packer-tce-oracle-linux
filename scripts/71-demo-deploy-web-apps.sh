#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Deploy Demo Apps
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# NOTE: If the Docker host machine is rebooted, the cluster will need 
#       to be re-created.
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

source ${HOME}/scripts/00-tce-build-variables.sh

if [ ! -f ${HOME}/.kube/config-tce-workload ]; then
    echo "File: ${HOME}/.kube/config-tce-workload missing ..."
    echo "Exiting ..."
    exit 1
fi

export KUBECONFIG=${HOME}/.kube/config-tce-workload
kubectl config use-context tce-workload-admin@tce-workload

echo "Installing repository to the default namespace."
echo "Adding TCE package repository..."

REPO_NAME="tce-main-latest"
REPO_URL="projects.registry.vmware.com/tce/main:latest"
REPO_NAMESPACE="default"

tanzu package repository add ${REPO_NAME} --namespace ${REPO_NAMESPACE} --url ${REPO_URL}
tanzu package repository get ${REPO_NAME} -o json | jq -r '.[0].status | select (. != null)'

echo "Sleeping 60 seconds ... wait for packages to be available"
sleep 60

echo "#--------------------------------------------------------------"
echo "TCE package repository -> Checking available package list ..."
echo "#--------------------------------------------------------------"
tanzu package available list

echo "#--------------------------------------------------------------"
echo "TCE package repository -> Checking installed package list ..."
echo "#--------------------------------------------------------------"
tanzu package installed list

#--------------------------------------------------------------------------
# Demo #1
#--------------------------------------------------------------------------

DEMO_FLUENT_BIT_PACKAGE="fluent-bit.community.tanzu.vmware.com"

echo "Demo App #1: Installing fluent-bit -- Fluent Bit is a fast Log Processor and Forwarder"
tanzu package available list ${DEMO_FLUENT_BIT_PACKAGE}
fluentbit_version=$(tanzu package available list ${DEMO_FLUENT_BIT_PACKAGE} -o json | jq -r '.[0].version | select(. !=null)')
tanzu package install fluent-bit --package-name ${DEMO_FLUENT_BIT_PACKAGE} --version "${fluentbit_version}"
tanzu package installed list
kubectl -n tanzu-system-loggin get all

#--------------------------------------------------------------------------
# Demo #2
#--------------------------------------------------------------------------

echo "Demo App #2: Installing assembly-webapp"
kubectl create namespace assembly
kubectl apply -f ${HOME}/scripts/71-assembly-deployment.yaml

echo "Waiting for assembly-webapp pods to be created."
for POD in `kubectl -n assembly get pods | grep -v NAME | awk '{print $1}'`
do
  kubectl -n assembly wait --for=condition=Ready pod/${POD} --timeout=300s
done

kubectl get pods,services --namespace=assembly
ExternalIp=`kubectl -n assembly get service/assembly-service | grep LoadBalancer | awk '{print $4}'`
echo " "
echo "To access assembly webapp, go to http://${ExternalIp}:8080"
echo " "

## To remove the assembly webapp
## kubectl delete --all  deployments,services,replicasets --namespace=assembly
## kubectl delete namespace assembly