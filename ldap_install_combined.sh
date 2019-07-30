#!/bin/bash

if [[ $(uname -n | head -c 10) == "ldapserver" ]];then
  #chmod 755 /local/repository/ldap_install.sh
  /local/repository/ldap_install.sh
  exit 0
else
  #sleep 2m
  #chmod 755 /local/repository/clientSide_ldap.sh
  /local/repository/clientSide_ldap.sh
  if [[ $(uname -n | head -c 9) == "nfsserver" ]];then
    sudo apt-get install -y nfs-kernel-server
    sudo chown nobody:nogroup /nfs/home
    
    sudo bash<<EOF
    echo "/nfs/home 192.168.1.3(rw,sync,no_root_squash,no_subtree_check)" > /etc/exports
    EOF
    
    sudo systemctl restart nfs-kernel-server
    exit 0
    
  else
    sudo apt-get install -y nfs-common
    sudo mkdir -p /nfs/home
    sudo mount 192.168.1.2:/nfs/home /nfs/home
    exit 0
  fi
  exit 0
fi
