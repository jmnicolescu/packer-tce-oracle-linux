#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Install / ReInstall [ 33-tce-install.sh ]
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 33-tce-install.sh"
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run $0 script as root"
  echo "Exiting script 33-tce-install.sh"
  exit 1
fi

rm -rf ${HOME}/.kube-tkg ${HOME}/.kube
rm -rf ${HOME}/.tanzu ${HOME}/.config/tanzu  ${HOME}.cache/tanzu

#--------------------------------------------------------------------------------------
# Install Tanzu Community Edition
#--------------------------------------------------------------------------------------

echo "Installing Tanzu Community Edition from ${HOME}/tce-linux-amd64-v${TCE_VERSION}"
cd ${HOME}/tce
tar xzvf tce-linux-amd64-v${TCE_VERSION}.tar.gz

cd ${HOME}/tce/tce-linux-amd64-v${TCE_VERSION}
./uninstall.sh
./install.sh

echo "Checking Tanzu Community Edition version version"
tanzu version
tanzu plugin list

# Making sure that we are using the correct version of kubectl
sudo cp /usr/local/bin/kubectl-${K8S_VERSION} /usr/local/bin/kubectl

echo "Done 33-tce-install.sh"