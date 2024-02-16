#!/bin/bash

if [ "$1" == "--raw" ]; then
    echo "HOST CPUS RAM"
    for vm in $(virsh list --all --name); do
        cpus=$(virsh dominfo $vm | grep 'CPU(s)' | awk '{print $2}')
        ram=$(virsh dominfo $vm | grep 'Max memory' | awk '{print $3 $4}')
        echo "$vm $cpus $ram"
    done
else
    "$0" --raw | column -t
fi
