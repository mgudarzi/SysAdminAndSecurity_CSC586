#!/bin/bash

if [[ $(uname -n | head -c 10) == "ldapserver" ]];then
  /local/repository/ldap_install.sh
  exit 0
else
  sleep 2m
  /local/repositoryclientSide_ldap.sh
  exit 0
fi
