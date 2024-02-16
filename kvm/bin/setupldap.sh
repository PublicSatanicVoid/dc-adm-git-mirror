#!/bin/bash

apt install -y debconf-utils

echo "ldap-auth-config ldap-auth-config/ldapns/ldap-server string ldap://eagmspvldap01" | sudo debconf-set-selections
echo "ldap-auth-config ldap-auth-config/dbrootlogin boolean false" | sudo debconf-set-selections
echo "ldap-auth-config ldap-auth-config/dblogin boolean false" | sudo debconf-set-selections
echo "ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=dc,dc=homelab,dc=net" | sudo debconf-set-selections
echo "ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3" | sudo debconf-set-selections

apt install -y libnss-ldap libpam-ldap ldap-utils

sudo sed -i '/^passwd:/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/^group:/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/^shadow:/ s/$/ ldap/' /etc/nsswitch.conf

systemctl restart nscd


