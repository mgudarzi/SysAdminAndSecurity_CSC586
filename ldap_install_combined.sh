#!/bin/bash

if [[ $(uname -n | head -c 10) == "ldapserver" ]];then
  chmod 755 /local/repository/ldap_install.sh
  /local/repository/ldap_install.sh
  exit 0
else
  sleep 1m
  chmod 755 /local/repository/clientSide_ldap.sh
  /local/repositoryclientSide_ldap.sh
  exit 0
fi
