#!/bin/bash

#updates the system repo database
sudo apt update

#change the fronend to noninteractive, avoiding prompts for automation
export DEBIAN_FRONTEND=noninteractive


#pre-seeding debconf with slapd.debconf file 
cat /local/repository/slapd.debconf | sudo debconf-set-selections

#installs slapd and ldap-utils along with all their dependencies
sudo apt install ldap-utils slapd -q -y



# saves the hashed password retunred by slappasswd
PASSHASH=$(slappasswd -s rammy)

# writes the contents of users.ldif file 
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

# sets the firewall rule to allow ldap service
sudo ufw allow ldap

ldapadd -f /local/repository/basedn.ldif -x -D "cn=admin,dc=clemson,dc=cloudlab,dc=us" -w admin

#populdate "student" user info from users.ldif
ldapadd -f /local/repository/users.ldif -x -D "cn=admin,dc=clemson,dc=cloudlab,dc=us" -w admin
