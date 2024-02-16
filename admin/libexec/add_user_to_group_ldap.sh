#!/bin/bash

source /tools/net/etc/infra-hosts.rc

if [ -z "$1" ]; then
	echo "Error: Must specify user name as first argument"
	exit 1
fi

if [ -z "$2" ]; then
	echo "Error: Must specify group name as second argument"
	exit 1
fi

if [ "$(hostname)" != "$LDAP_HOST" ]; then
	echo "Error: Must run $0 on LDAP server"
	exit 1
fi


tempfile=temp$RANDOM.ldif
cd /proj/ldapdata
cp /tools/ldap/etc/useradd2grouptemplate.ldif $tempfile
sed -i "s/GROUPNAME/$2/g" $tempfile
sed -i "s/USERNAME/$1/g" $tempfile

ldapmodify -x -D "$LDAP_ADMIN_DN" -W -f $tempfile

rm $tempfile


