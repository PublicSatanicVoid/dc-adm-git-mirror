#!/bin/bash

source /tools/net/etc/infra-hosts.rc

if [ -z "$1" ]; then
	echo "Error: Must specify group name as first argument"
	exit 1
fi

if [ -z "$2" ]; then
	echo "Error: Must specify GID as second argument"
	exit 1
fi

if [ "$(hostname)" != "$LDAP_HOST" ]; then
	echo "Error: Must run $0 on LDAP server"
	exit 1
fi


cd /proj/ldapdata/groups
cp /tools/ldap/etc/grouptemplate.ldif "$1".ldif
sed -i "s/GROUPNAME/$1/g" "$1".ldif
sed -i "s/GROUP_GID/$2/g" "$1".ldif

ldapadd -x -D "$LDAP_ADMIN_DN" -W -f "$1".ldif


