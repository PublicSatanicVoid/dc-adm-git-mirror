#!/bin/bash

source /tools/net/etc/infra-hosts.rc

read -p "User name:  " username
read -p "Group name: " groupname

read -p "Press Enter to add user to group, Ctrl+C to abort"

echo "=== Updating group entry in LDAP ==="
ssh -t root@$LDAP_HOST sudo -u openldap /tools/admin/libexec/add_user_to_group_ldap.sh $username $groupname


