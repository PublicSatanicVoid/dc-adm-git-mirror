#!/bin/bash

if [[ -z "$1" ]]; then
	echo "usage: setupvm.sh <LAN IP>"
	exit 1
fi


source /tools/net/etc/infra-hosts.rc


hostname=$(hostname)
echo "--------------------------------------------------"
echo "Virtual machine setup parameters"
echo "--------------------------------------------------"
echo "Hostname:     $hostname"
echo "New IP:       $1"
echo "Domain name:  $DOMAIN"
echo "DNS server:   $DNS_HOST  ($DNS_IP)"
echo "NIS server:   $NIS_HOST  ($NIS_IP)"
echo "LDAP server:  $LDAP_HOST ($LDAP_IP)"
echo "NAS cluster:  $NAS_CLUSTER"
echo "--------------------------------------------------"
echo
read -p "Press Enter to continue, Ctrl+C to quit: "


echo "### Setting up root user ###"
mkdir -p /root/.ssh
chmod u=rwx,go= /root/.ssh
cat /tools/admin/etc/sshkeys/admin_user_id_rsa.pub >> /root/.ssh/authorized_keys
echo "!! Please enter new root password now:"
passwd root


echo "### Setting up local failsafe user ###"
groupadd -g 900 failsafe
useradd -Mr -u 900 -g 900 failsafe
echo "failsafe ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "!! Please enter new failsafe password now:"
passwd failsafe


#echo "### Setting up default firewall rules ###"
#/tools/kvm/bin/setupufw.sh
echo "### Updating packages ###"
yum update -y


echo "### Enabling login ACL support ###"
sed -i '/#\s*account\s*required\s*pam_access.so/s/^# *//' /etc/pam.d/login
sed -i '/#\s*account\s*required\s*pam_access.so/s/^# *//' /etc/pam.d/sshd
echo "+ : ALL : ALL" >| /etc/security/access.conf


echo "### Installing required packages ###"
echo "Base packages..."
yum install -y nfs-utils ypbind autofs nss-pam-ldapd openldap-clients


echo "### Applying static IP and hostname ###"
echo "$1 $hostname.$DOMAIN $hostname" >> /etc/hosts
sed -i 's/127\.0\.1\.1 //g' /etc/hosts
hostnamectl set-hostname "$hostname"
nmcli con modify eth0 \
	ipv4.addresses "$1/16" \
	ipv4.gateway "10.0.0.1" \
	ipv4.dns-search "$DOMAIN"
nmcli con down eth0
nmcli con up eth0

#/tools/net/bin/netrestart.sh

systemctl restart network
systemctl restart NetworkManager


echo "### Configuring NIS client ###"
echo "ypserver $NIS_IP" >> /etc/yp.conf
echo "domain $DOMAIN server $NIS_HOST" >> /etc/yp.conf
#echo "$DOMAIN" >| /etc/defaultdomain
#sed -i 's/NISCLIENT=false/NISCLIENT=true/g' /etc/default/nis


echo "### Configuring auto-mounter ###"
echo "+auto.master" >| /etc/auto.master
echo "+auto.home" >| /etc/auto.home
echo "+auto.proj" >| /etc/auto.proj
echo "+auto.top" >| /etc/auto.top


echo "### Configuring LDAP authentication ###"
authconfig \
	--enableldap \
	--enableldapauth \
	--ldapserver="$LDAP_HOST" \
	--ldapbasedn="$LDAP_BASE_DN" \
	--update
echo "%sudo ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "### Updating nsswitch.conf to use NIS and LDAP ###"
cp /tools/kvm/etc/nsswitch-centos.conf /etc/nsswitch.conf


echo "### Restarting NSCD, NIS and autofs ###"
systemctl enable --now nscd
systemctl restart nscd
systemctl enable --now ypbind
systemctl restart ypbind
systemctl enable --now autofs
systemctl restart autofs


echo "### Setting root shell to zsh ###"
yum install -y zsh
chsh -s /bin/zsh root
cp /tools/etc/zshrc.template /root/.zshrc
sed -i 's/%f%K%B/%f%K%B%F{red}/g' /root/.zshrc
sed -i 's/WHOAMI%b@/WHOAMI%f%b@/g' /root/.zshrc


echo "### Installing additional packages ###"
yum install -y \
	python3 \
	gcc gcc-c++ \
	openssl-devel \
	libnl libnl-devel libnl3 libnl3-devel \
	wget \
	make automake \
	git \
	vim-common vim-enhanced \
	iotop


echo "### Setup complete, logout then exit the console with Ctrl+] ###"

