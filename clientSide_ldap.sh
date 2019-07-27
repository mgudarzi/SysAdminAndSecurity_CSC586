#!/bin/bash

#updates the system repo database
sudo apt update

#change the fronend to noninteractive, avoiding prompts for automation
export DEBIAN_FRONTEND=noninteractive

#pre-seeding debconf with ldap_auth_conifg.debconf file 
cat /local/repository/ldap-auth-config.debconf | sudo debconf-set-selections

#installs libnss-ldap libpam-ldap ldap-utils along with all their dependencies
sudo apt install -y -q libnss-ldap libpam-ldap ldap-utils

#changes to ldap.conf, nsswitch.conf , common-session, common-password 
sudo sed -i 's/uri ldapi:\/\/\//uri ldap:\/\/192.168.1.1\//g' /etc/ldap.conf
sudo sed -i 's/base dc=example,dc=net/base dc=clemson,dc=cloudlab,dc=us/g' /etc/ldap.conf
sudo sed -i 's/rootbinddn cn=manager,dc=example,dc=net/rootbinddn cn=admin,dc=clemson,dc=cloudlab,dc=us/g' /etc/ldap.conf
sudo sed -i '/passwd:/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/group:/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/# end of pam-auth-update config/ i session optional pam-mkhomedir.so  skel=/etc/skel  umsak=077' /etc/pam.d/common-session
sudo sed -i 's/use_authtok//g' /etc/pam.d/common-password

#fetches and prints details for a particular user
getent passwd student

#switches to "student" account
sudo su - student
