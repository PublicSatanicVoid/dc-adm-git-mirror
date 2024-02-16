#!/bin/bash

# Removes the local user with ID 1000 created during system install
# so the LDAP user with ID 1000 will be used instead

killall -9 -u admin_user

usermod -G root admin_user
groupdel -f admin_user
userdel admin_user

reboot

