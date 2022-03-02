#!/bin/sh

#--------------------------------------------------------------------------------------
# Oracle Linux OS - Install MS code [ 25-install-mscode.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 25-install-mscode.sh" 
echo "#--------------------------------------------------------------"

rpm --import https://packages.microsoft.com/keys/microsoft.asc

cat << EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Workaround buggy code versions 1.54, 1.55
#yum -y install code

yum -y install code-1.52.1-1608137084.el7.x86_64

yum -y install yum-plugin-versionlock
yum versionlock code

echo "Done 25-install-mscode.sh"