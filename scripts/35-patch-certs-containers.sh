#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Trust CAs [ 35-patch-certs-containers.sh ]
# Patching the bootstrap containers to trust the CAs
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
#--------------------------------------------------------------------------

for CONTAINER_ID in `docker ps | grep 'projects.registry.vmware.com' | awk '{print $1}'`
do
  echo "Found container ID --> $CONTAINER_ID"
  # Trust the CA certificates at OS level
  sudo docker cp -L /root/certs ${CONTAINER_ID}:/usr/local/share/ca-certificates/
  sudo docker exec ${CONTAINER_ID} /usr/sbin/update-ca-certificates
  # Trust the CA certificates at Containerd level
  sudo docker exec ${CONTAINER_ID} mkdir -p /etc/containerd/certs.d
  sudo docker cp -L /etc/docker/certs.d ${CONTAINER_ID}:/etc/containerd/certs.d
  # podman, crictl may read the CA certificates from
  sudo docker exec ${CONTAINER_ID} mkdir -p /etc/containers/certs.d
  sudo docker cp -L /etc/docker/certs.d ${CONTAINER_ID}:/etc/containers/certs.d

done

