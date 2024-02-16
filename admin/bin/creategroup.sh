#!/bin/bash

source /tools/net/etc/infra-hosts.rc

read -p "Group name: " groupname
read -p "GID:        " gid

read -p "Press Enter to create group, Ctrl+C to abort"

echo "=== Creating group entry in LDAP ==="
ssh -t root@$LDAP_HOST sudo -u openldap /tools/admin/libexec/create_group_ldap.sh $groupname $gid


