#!/bin/bash

if [ -z "$1" ]; then
	echo "$(basename "$0") <new hostname>"
	exit 1
fi

curr_hostname="$(hostname)"

sed -i "s/$curr_hostname/$1/g" /etc/hosts

hostnamectl set-hostname "$1"
/tools/net/bin/netrestart.sh



