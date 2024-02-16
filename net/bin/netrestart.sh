systemctl restart systemd-networkd systemd-resolved
resolvectl flush-caches
nscd -i hosts
