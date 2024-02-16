#!/bin/bash

# To allow public traffic on X port:
#	ufw allow from any to any port X

ufw allow from 10.0.0.0/16 to any
ufw allow from 192.168.1.0/24 to any
ufw allow from 127.0.0.1 to any
ufw allow from 10.0.2.5 to any port 22 proto tcp
ufw route allow in on br0 out on br0 to any
ufw logging on
ufw default deny incoming
ufw enable

