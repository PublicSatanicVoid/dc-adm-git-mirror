#!/bin/bash

if [ -z "$5" ]; then
	echo "Error: Usage: $0 <IMAGE> <HOSTNAME> <MEMORY_MiB> <VCPUS> <DISK_GiB>"
	echo "	Valid images are: ubuntu22, cent79"
	exit 1
fi

if [[ "$1" == "ubuntu22" ]]; then
	echo "Selected image: Ubuntu Server 22.04.3 LTS"
	ISO='/tools/kvm/iso/ubuntu-22.04.3-live-server-amd64.iso'
elif [[ "$1" == "cent79" ]]; then
	echo "Selected image: CentOS 7.9 (2022)"
	ISO='/tools/kvm/iso/CentOS-7-x86_64-Everything-2207-02.iso'
else
	echo "Error: Invalid image type"
fi

#echo "### Go through the install process, then shut down the VM and exit the virsh console to finish installation! ###"
#read -p "Press Enter to continue, Ctrl+C to abort"
#echo

virt-install  \
	--name "$2"  \
	--location "$ISO"  \
	--memory "$3"  \
	--vcpus "$4"  \
	--disk size="$5"  \
	--graphics none  \
	--xml ./domain/on_crash=restart  \
	--autostart  \
	--extra-args 'console=ttyS0,115200n8'

#virsh shutdown "$1"

# --xml ./domain/on_crash=restart
#virsh dumpxml "$1" > config.xml
#xmlstarlet ed -u "/domain/on_crash" -v "restart" config.xml > config_mod.xml
#virsh define config_mod.xml
#rm config.xml config_mod.xml

#virsh start "$1"

echo "### Setup complete ###"

