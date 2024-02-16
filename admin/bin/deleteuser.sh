#!/bin/bash

source /tools/net/etc/infra-hosts.rc

if [ -z "$1" ]; then
	echo "Error: Must specify username to delete as argument"
	exit 1
fi

echo "Deleting user..."
ssh -t root@$LDAP_HOST sudo -u openldap ldapdelete -x -D "$LDAP_ADMIN_DN" -W "uid=$1,ou=People,$LDAP_BASE_DN"

echo "Deleting user group..."
ssh -t root@$LDAP_HOST sudo -u openldap ldapdelete -x -D "$LDAP_ADMIN_DN" -W "cn=$1,ou=Groups,$LDAP_BASE_DN"

echo "Deletion complete"
