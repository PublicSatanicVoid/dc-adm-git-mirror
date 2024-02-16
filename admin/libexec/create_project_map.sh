#!/bin/bash

source /tools/net/etc/infra-hosts.rc

if [ -z "$1" ]; then
	echo "Error: Must specify project label as first argument"
	exit 1
fi

if [ "$(hostname)" != "$NIS_HOST" ]; then
	echo "Error: Must only run $0 on NIS server"
	exit 1
fi

echo "$1 -fstype=nfs4,rw $NAS_CLUSTER:/export/proj/$1" >> /etc/auto.proj

cd /var/yp
make

