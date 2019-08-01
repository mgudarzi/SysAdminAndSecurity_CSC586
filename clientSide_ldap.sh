#!/bin/bash

ADMIN_PASSWORD="admin"
#updates the system repo database
sudo apt update

#change the fronend to noninteractive, avoiding prompts for automation
export DEBIAN_FRONTEND=noninteractive

#pre-seeding debconf with ldap_auth_conifg.debconf file 
echo -e " 
ldap-auth-config        ldap-auth-config/rootbindpw     password password
ldap-auth-config        ldap-auth-config/bindpw password password
ldap-auth-config        ldap-auth-config/binddn string  cn=admin,dc=clemson,dc=cloudlab,dc=us
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/dblogin        boolean false
libpam-runtime          libpam-runtime/profiles multiselect     unix, ldap, systemd, capability
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=clemson,dc=cloudlab,dc=us
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean true
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select  3
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=admin,dc=clemson,dc=cloudlab,dc=us
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldap://192.168.1.1
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean true
" | sudo debconf-set-selections

#installs libnss-ldap libpam-ldap ldap-utils along with all their dependencies
sudo apt install -y libnss-ldap -y libpam-ldap ldap-utils

#changes to ldap.conf, ldap.secret, nsswitch.conf, common-session, common-password

# sudo sed -i 's/uri ldapi:\/\/\//uri ldap:\/\/192.168.1.1\//g' /etc/ldap.conf
# sudo sed -i 's/base dc=example,dc=net/base dc=clemson,dc=cloudlab,dc=us/g' /etc/ldap.conf
# sudo sed -i 's/rootbinddn cn=manager,dc=example,dc=net/rootbinddn cn=admin,dc=clemson,dc=cloudlab,dc=us/g' /etc/ldap.conf
sudo sed -i '/passwd:/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/group:/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/# end of pam-auth-update config/ i session optional pam_mkhomedir.so  skel=/etc/skel  umsak=077' /etc/pam.d/common-session
sudo sed -i 's/use_authtok//g' /etc/pam.d/common-password
# sudo bash <<EOF
# echo $ADMIN_PASSWORD > /etc/ldap.secret
# EOF
# sudo chmod 600 /etc/ldap.secret

#fetches and prints details for a particular user 
getent passwd student
