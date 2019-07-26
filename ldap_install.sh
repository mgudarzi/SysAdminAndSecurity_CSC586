#!/bin/bash

sudo apt update
cat <<EOF >> /users/mg920115/ldapAutomate/debconf-slapd.conf 
slapd slapd/password1 password admin
slapd slapd/internal/adminpw password admin
slapd slapd/internal/generated_adminpw password admin
slapd slapd/password2 password admin
slapd slapd/unsafe_selfwrite_acl note
slapd slapd/purge_database boolean false
slapd slapd/domain string clemson.cloudlab.us
slapd slapd/ppolicy_schema_needs_update select abort installation
slapd slapd/invalid_config boolean true
slapd slapd/move_old_database boolean true
slapd slapd/backend select MDB
slapd shared/organization string WestChesterUniversity
slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
slapd slapd/password_mismatch note
EOF

export DEBIAN_FRONTEND=noninteractive
cat /users/mg920115/ldapAutomate/debconf-slapd.conf | sudo debconf-set-selections
sudo apt install ldap-utils slapd -y

cat <<EOF >> /users/mg920115/ldapAutomate/basedn.ldif
dn: ou=People,dc=clemson,dc=cloudlab,dc=us
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=clemson,dc=cloudlab,dc=us
objectClass: organizationalUnit
ou: Groups

dn: cn=CSC,ou=Groups,dc=clemson,dc=cloudlab,dc=us
objectClass: posixGroup
cn: CSC586
gidNumber: 5000
EOF


PASSHASH=$(slappasswd -s rammy)
cat <<EOF >> /users/mg920115/ldapAutomate/users.ldif
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
ldapadd -f /users/mg920115/ldapAutomate/basedn.ldif -x -D "cn=admin,dc=clemson,dc=cloudlab,dc=us" -w admin
ldapadd -f /users/mg920115/ldapAutomate/users.ldif -x -D "cn=admin,dc=clemson,dc=cloudlab,dc=us" -w admin
