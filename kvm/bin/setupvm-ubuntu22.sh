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
cat /tools/admin/etc/sshkeys/admin_user_id_rsa.pub >> /root/.ssh/authorized_keys
echo "!! Please enter new root password now:"
passwd root


echo "### Setting up local failsafe user ###"
groupadd -g 900 failsafe
useradd -Mr -u 900 -g 900 failsafe
echo "failsafe ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "!! Please enter new failsafe password now:"
passwd failsafe


echo "### Setting up default firewall rules ###"
/tools/kvm/bin/setupufw.sh


echo "### Enabling login ACL support ###"
sed -i '/#\s*account\s*required\s*pam_access.so/s/^# *//' /etc/pam.d/login
sed -i '/#\s*account\s*required\s*pam_access.so/s/^# *//' /etc/pam.d/sshd
echo "+ : ALL : ALL" >| /etc/security/access.conf


echo "### Ensuring package manager is up to date ###"
apt update
apt dist-upgrade -y


echo "### Installing required packages ###"
echo "Base packages..."
apt install -y \
	nfs-common nis autofs debconf-utils \
	zsh btop iotop neofetch cpufetch \
	fd-find

echo "LDAP packages..."
# Pre-configure LDAP so we're not prompted interactively
echo "ldap-auth-config ldap-auth-config/ldapns/ldap-server string ldap://$LDAP_HOST" | sudo debconf-set-selections
echo "ldap-auth-config ldap-auth-config/dbrootlogin boolean false" | sudo debconf-set-selections
echo "ldap-auth-config ldap-auth-config/dblogin boolean false" | sudo debconf-set-selections
echo "ldap-auth-config ldap-auth-config/ldapns/base-dn string $LDAP_BASE_DN" | sudo debconf-set-selections
echo "ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3" | sudo debconf-set-selections

apt install -y libnss-ldap libpam-ldap ldap-utils

sudo sed -i '/^passwd:/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/^group:/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed -i '/^shadow:/ s/$/ ldap/' /etc/nsswitch.conf


echo "### Applying static IP and hostname ###"
cp /tools/kvm/etc/01-netcfg-vm.yaml /etc/netplan
sed -i "s/10\.0\.0\.0\/16/$1\/16/g" /etc/netplan/01-netcfg-vm.yaml
netplan apply
echo "$1 $hostname.$DOMAIN $hostname" >> /etc/hosts
sed -i 's/127\.0\.1\.1 //g' /etc/hosts
hostnamectl set-hostname "$hostname"
/tools/net/bin/netrestart.sh


echo "### Configuring NIS client ###"
echo "ypserver $NIS_IP" >> /etc/yp.conf
echo "domain $DOMAIN server $NIS_HOST" >> /etc/yp.conf
echo "$DOMAIN" >| /etc/defaultdomain
sed -i 's/NISCLIENT=false/NISCLIENT=true/g' /etc/default/nis


echo "### Configuring auto-mounter ###"
echo -e "\nautomount: files nis" >> /etc/nsswitch.conf

echo "+auto.master" >| /etc/auto.master
echo "+auto.home" >| /etc/auto.home
echo "+auto.proj" >| /etc/auto.proj
echo "+auto.top" >| /etc/auto.top


echo "### Restarting NSCD, NIS and autofs ###"
systemctl restart nscd
systemctl enable --now ypbind
systemctl restart ypbind
systemctl restart autofs


echo "### Setting root shell to zsh ###"
chsh -s /bin/zsh root
cp /tools/etc/zshrc.template /root/.zshrc
sed -i 's/%f%K%B/%f%K%B%F{red}/g' /root/.zshrc
sed -i 's/WHOAMI%b@/WHOAMI%f%b@/g' /root/.zshrc


echo "### Setup complete, logout then exit the console with Ctrl+] ###"

