#!/bin/bash


sed -i '/#\s*account\s*required\s*pam_access.so/s/^# *//' /etc/pam.d/login
sed -i '/#\s*account\s*required\s*pam_access.so/s/^# *//' /etc/pam.d/sshd
if [ "$1" == "--secure" ]; then
	echo "- : ALL EXCEPT root failsafe (sysadmins) : ALL" >| /etc/security/access.conf
else
	echo "+ : ALL : ALL" >| /etc/security/access.conf
fi

systemctl restart sshd

