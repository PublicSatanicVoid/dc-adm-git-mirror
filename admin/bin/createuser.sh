#!/bin/bash

source /tools/net/etc/infra-hosts.rc

read -p "Username: " username
read -p "UID:      " uid

read -p "Press Enter to create user, Ctrl+C to abort"

echo "=== Creating user home NFS share ==="
ssh root@$NAS_ADMIN_HOST /tools/admin/libexec/create_ceph_nfs_share.sh "export/home/$username" $uid $uid rw

echo "=== Adding user home to NIS automount map ==="
ssh root@$NIS_HOST /tools/admin/libexec/create_user_home_map.sh $username

echo "=== Creating user entry in LDAP ==="
ssh -t root@$LDAP_HOST sudo -u openldap /tools/admin/libexec/create_user_ldap.sh $username $uid


