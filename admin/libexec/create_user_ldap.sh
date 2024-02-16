#!/bin/bash

source /tools/net/etc/infra-hosts.rc

if [ -z "$1" ]; then
	echo "Error: Must specify username as first argument"
	exit 1
fi

if [ -z "$2" ]; then
	echo "Error: Must specify UID as second argument"
	exit 1
fi

if [ "$(hostname)" != "$LDAP_HOST" ]; then
	echo "Error: Must run $0 on LDAP server"
	exit 1
fi

read -p "Enter display name: " displayname
read -p "Enter surname: " surname

echo "Enter the *user*'s password twice, then the admin password once:"
password_hash=$(slappasswd)
escaped_password_hash=$(printf '%s\n' "$password_hash" | sed -s 's/[\/&]/\\&/g')

cd /proj/ldapdata/users
cp /tools/ldap/etc/usertemplate.ldif "$1".ldif
sed -i "s/USERNAME/$1/g" "$1".ldif
sed -i "s/USER_UID/$2/g" "$1".ldif
sed -i "s/USER_SN/$surname/g" "$1".ldif
sed -i "s/USER_DISPLAYNAME/$displayname/g" "$1".ldif
sed -i "s/USER_PASSWORD/$escaped_password_hash/g" "$1".ldif
sed -i "s/USER_HOME/\/home\/$1/g" "$1".ldif

ldapadd -x -D "$LDAP_ADMIN_DN" -W -f "$1".ldif


