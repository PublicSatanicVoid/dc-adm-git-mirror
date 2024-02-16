# Homelab scripts

This is a collection of scripts I use for configuring and managing my Linux homelab.

My homelab runs on Ubuntu servers hosting Ubuntu and CentOS VMs. Service hosts, admin
hosts, storage hosts, testing hosts, all of them are VMs.

At some point I will probably switch to Ansible or some other standard automation
tooling, but for learning the ropes of Linux administration I believe there is no better
way than rolling up your sleeves and setting things up manually.

**Note** These scripts reference 'admin_user' as the primary user in some places. You
should replace this with the actual username you plan to daily-drive.

## Quick rundown of my hardware/software setup
for reference of course, not bragging!

- 2x hypervisors: PowerEdge R630, each with a 256GB SSD for the OS, a 1TB HDD for `/var`
(mainly used for the VM images),
  and 2x 2TB HDDs each passed through directly to the storage nodes
  - Connected to each other via 10G networking, and to the router via 1G. Switch is a
  Netgear something-or-other.
- 1x VM for DNS, running BIND9
- 1x VM for LDAP, running slapd
- 1x VM for NIS, running ypserv
- 1x VM for Ceph mgr, running cephadm
- 4x VM for Ceph nodes (object storage daemons / OSDs), running Dockerized Ceph
  - These also run Ganesha NFS nodes, also Dockerized via Ceph
  - Although the hosts are connected via 10Gb, there is no separation of frontend and
  backend networks, limiting total throughput. Probably I will fix this at some point.
- 3x VM for admin / software builds. 1 per host, plus an extra of each OS I run.
- 1x VM for proxy server, running HAProxy
- 2x VM for web servers, running <some Python framework, honestly don't remember> and
keepalived
- A bunch of additional VMs for experimentation and fun!

The default gateway is `10.0.0.1` and the subnet mask is `255.255.0.0`. These values are
assumed in many places in these scripts.


## Guide to the layout

These all reside on an NFS share mounted at `/tools` on my system.

`admin` -- routine administration of a typical server cluster: creating and deleting
users/projects/network shares. broadly, configuring the infra you already have
- `admin/bin` -- scripts intended to be called directly
- `admin/libexec` -- scripts intended to be called internally by the tools

`etc` -- general configuration files. symlink to `usr` on my system.

`kvm` -- scripts for setting up and managing KVM.
- `kvm/bin` -- scripts to be called directly
- `kvm/bin/hypervisor-setup-ubuntu22.sh` -- installs the required packages to run KVM on a
bare metal Ubuntu 22 machine
- `kvm/bin/newvm.sh` -- creates and launches a new VM. NOTE, this expects ISOs at `kvm/iso`; I don't upload these for likely copyright reasons.
- `kvm/bin/setupvm-<OS>.sh` -- run these once a new VM is launched to configure it for the
suite of services here (LDAP, NIS, NFS, ...)
- `kvm/etc` -- blueprints for VMs
- `kvm/etc/01-netcfg-vm.yaml` -- Replace the values here with your own!

`ldap` -- scripts for LDAP.
- `ldap/etc` -- template LDIF files.

`net` -- scripts for network management.
- `net/bin` -- scripts to be called directly
- `net/etc` -- example/skeleton configs.
- `net/etc/infra-hosts.rc` -- important file used by other scripts in this repo, contains
critical hostnames/IPs and domain information -- Replace the values here with your own!

`stress` -- utils for stress testing.

`usr` -- random collection of stuff that is nice for any user of your system.

