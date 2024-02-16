#!/bin/bash

if [ -f /tools/usr/etc/root.zshrc.template ]; then
	rm -f /root/.zshrc
	cp /tools/usr/etc/root.zshrc.template /root/.zshrc
else
	echo "Can't find template"
fi
