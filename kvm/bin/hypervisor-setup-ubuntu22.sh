#!/bin/bash

apt -y install \
	bridge-utils cpu-checker libvirt-clients libvirt-daemon \
	qemu qemu-kvm virt-manager libvirt-daemon-system virtinst \
	bridge-utils xmlstarlet

kvm-ok

systemctl enable --now libvirtd

