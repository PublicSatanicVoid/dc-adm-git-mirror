#!/bin/bash

virsh shutdown "$1"

virsh autostart "$1"
virsh dumpxml "$1" > config.xml
xmlstarlet ed -u "/domain/on_crash" -v "restart" config.xml > config_mod.xml
virsh define config_mod.xml
rm config.xml config_mod.xml

virsh start "$1"

echo "### Setup complete ###"

