#!/bin/bash

if [[ $(uname -n | head -c 10) == "ldapserver" ]];then
  sudo apt update


  export DEBIAN_FRONTEND=noninteractive
  cat /local/repository/slapd.debsetting | sudo debconf-set-selections
  sudo apt install ldap-utils slapd -y




  PASSHASH=$(slappasswd -s rammy)
  cat <<EOF > /local/repository/users.ldif
  dn: uid=student,ou=People,dc=clemson,dc=cloudlab,dc=us
  objectClass: inetOrgPerson
  objectClass: posixAccount
  objectClass: shadowAccount
  uid: student
  sn: Ram
  givenName: Golden
  cn: student
  displayName: student
  uidNumber: 10000
  gidNumber: 5000
  userPassword: $PASSHASH
  gecos: Golden Ram
  loginShell: /bin/dash
  homeDirectory: /home/student
  EOF

  sudo ufw allow ldap
  ldapadd -f /local/repository/basedn.ldif -x -D "cn=admin,dc=clemson,dc=cloudlab,dc=us" -w admin
  ldapadd -f /local/repository/users.ldif -x -D "cn=admin,dc=clemson,dc=cloudlab,dc=us" -w admin
  
else

  sleep 2m
  sudo apt update


  export DEBIAN_FRONTEND=noninteractive
  
  cat /local/repository/ldap-auth-config.debsetting | sudo debconf-set-selections
  sudo DEBIAN_FRONTEND=noninteractive aptitude install -y -q ldap-auth-client
 #sudo apt install -y libnss-ldap libpam-ldap ldap-utils
 #sudo apt install ldap-auth-config ldap-utils -y
  sudo sed -i 's/uri ldapi:\/\/\//uri ldap:\/\/192.168.1.1\//g' /etc/ldap.conf
  sudo sed -i 's/base dc=example,dc=net/base dc=clemson,dc=cloudlab,dc=us/g' /etc/ldap.conf
  sudo sed -i 's/rootbinddn cn=manager,dc=example,dc=net/rootbinddn cn=admin,dc=clemson,dc=cloudlab,dc=us/g' /etc/ldap.conf
  sudo sed -i '/passwd:/ s/$/ ldap/' /etc/nsswitch.conf
  sudo sed -i '/group:/ s/$/ ldap/' /etc/nsswitch.conf
  sudo sed -i '/# end of pam-auth-update config/ i session optional pam-mkhomedir.so  skel=/etc/skel  umsak=077' /etc/pam.d/common-session
  sudo sed -i 's/use_authtok//g' /etc/pam.d/common-password

  getent passwd student

  sudo su - student



fi
