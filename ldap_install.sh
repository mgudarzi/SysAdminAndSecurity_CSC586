#!/bin/bash

sudo su - && apt update
cd
export DEBIAN_FRONTEND=noninteractive

echo -e "slapd slapd/root_password password admin" | debconf-set-selections
echo -e "slapd slapd/root_password_again password admin" | debconf-set-selections
echo -e "slapd slapd/internal/adminpw password admin" | debconf-set-selections
echo -e "slapd slapd/internal/generated_adminpw password admin" | debconf-set-selections
echo -e "slapd slapd/password2 password amin" | debconf-set-selections
echo -e "slapd slapd/password1 password admin" | debconf-set-selections
echo -e "slapd slapd/domain string acu.local" | debconf-set-selections

apt-get install -y slapd ldap-utils

