#!/bin/sh

#--------------------------------------------------------------------------------------
# CentOS 7 - First set of OS customization 
#          - Install & configure postfix
#--------------------------------------------------------------------------------------

HOSTNAME=`hostname`

echo "#--------------------------------------------------------------"
echo "# Starting 22-install-postfix.sh" 
echo "#--------------------------------------------------------------"

yum -y install postfix mailx

## firewall-cmd --permanent --zone=public --add-service=smtp
## firewall-cmd --permanent --zone=public --add-port=25/tcp
## firewall-cmd --reload

systemctl enable postfix
systemctl start postfix

#--------------------------------------------------------------------------------------
# Postfix main configuration file ---> /etc/postfix/main.cf
#--------------------------------------------------------------------------------------

# check Postfix version 
postconf mail_version

# The netstat utility tells us that the Postfix master process is listening on TCP port 25 
netstat -lnpt | grep master
postconf -e "inet_interfaces = all"
postconf inet_interfaces
postconf -e "inet_protocols = all"
postconf inet_protocols
postconf -e "myhostname = ${HOSTNAME}.flexlab.local"
postconf myhostname
postconf -e "mydomain = flexlab.local"
postconf -e "myorigin = flexlab.local"
postconf mydomain
postconf -e "mydestination = flexlab.local, \$myhostname, localhost.\$mydomain, localhost"
postconf mydestination
postconf -e message_size_limit=52428800
postconf -e mailbox_size_limit=0
postconf -e "virtual_alias_maps = hash:/etc/postfix/virtual"

# - create virtual file
cat << EOF > /etc/postfix/virtual
#
# Execute the command "postmap /etc/postfix/virtual" to rebuild an 
# indexed file after changing the corresponding text file. 
#
# postmap /etc/postfix/virtual

juliusn@flexlab.local  juliusn
root@flexlab.local  root
EOF
postmap /etc/postfix/virtual

newaliases
systemctl restart postfix

echo "Done 22-install-postfix.sh"