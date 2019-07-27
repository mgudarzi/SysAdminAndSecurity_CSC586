#!/bin/bash

sudo apt update
mkdir

cat <<EOF >> /users/mg920115/.ldapAutomate/ldap-auth-config.debsetting
ldap_auth_config  ldap_auth_config/bindpw password admin
ldap_auth_config  ldap_auth_config/rootbindpw password
ldap_auth_config  ldap_auth_config/ldapns/ldap-server string ldap://192.168.1.1
ldap_auth_config  ldap_auth_config/pam_password select md5
ldap_auth_config  ldap_auth_config/move-to-debconf boolean true
ldap_auth_config  ldap_auth_config/rootbinddn string cn=admin,dc=clemson,dc=cloudlab,dc=us
ldap_auth_config  ldap_auth_config/override boolean true 
ldap_auth_config  ldap_auth_config/dbrootlogin boolean true
ldap_auth_config  ldap_auth_config/dblogin boolean false
libpam-runtime  libpam-runtime/profiles multiselect unix, ldap, systemd,capability
ldap_auth_config  ldap_auth_config/ldapns/ldap_version select 3
ldap_auth_config  ldap_auth_config/binddn string cn=proxyuser,dc=example,dc=net
ldap_auth_config  ldap_auth_config/ldapns/base-dn string dc=clemson,dc=cloudlab,dc=us
EOF

export DEBIAN_FRONTEND=noninteractive

cat /users/mg920115/.ldapAutomate/ldap-auth-config.debsetting | sudo debconf-set-selections
sudo apt install -y libnss-ldap libpam-ldap ldap-utils

sudo sed -i '/passwd:/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/group:/ s/$/ ldap/' /etc/cd nsswitch.conf
sudo sed -i '/# end of pam-auth-update config/ i session optional pam-mkhomedir.so  skel=/etc/skel  umsak=077' /etc/pam.d/common-session
sudo sed -i 's/use_authtok//g' /etc/pam.d/common-password

getent passwd student

sudo su - student
