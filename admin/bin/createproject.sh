#!/bin/bash

source /tools/net/etc/infra-hosts.rc

read -p "Project label:  " proj_label
read -p "Project owner:  " proj_owner
read -p "Project group:  " proj_group
read -p "Access (ro/rw): " proj_access

read -p "Press Enter to create project, Ctrl+C to abort"

echo "=== Creating project NFS share ==="
ssh root@$NAS_ADMIN_HOST /tools/admin/libexec/create_ceph_nfs_share.sh "export/proj/$proj_label" $proj_owner $proj_group $proj_access

echo "=== Adding project to NIS automount map ==="
ssh root@$NIS_HOST /tools/admin/libexec/create_project_map.sh "$proj_label"



