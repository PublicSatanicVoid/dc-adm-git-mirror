#!/bin/bash

source /tools/net/etc/infra-hosts.rc

if [ -z "$1" ]; then
	echo "Error: Must specify username as argument"
	exit 1
fi

if [ "$(hostname)" != "$NIS_HOST" ]; then
	echo "Error: Must only run $0 on NIS server"
	exit 1
fi

echo "$1 -fstype=nfs4,rw $NAS_CLUSTER:/export/home/$1" >> /etc/auto.home

cd /var/yp
make

