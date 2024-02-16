#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

apt update -y
apt dist-upgrade -yqq
exit $?
