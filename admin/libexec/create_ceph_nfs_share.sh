#!/bin/bash

source /tools/net/etc/infra-hosts.rc

if [ -z "$1" ]; then
	echo "Error: Must specify share label (export/X/Y) as first argument"
	exit 1
fi
if [ -z "$2" ]; then
	echo "Error: Must specify share owner as second argument"
	exit 1
fi
if [ -z "$3" ]; then
	echo "Error: Must specify share group as second argument"
	exit 1
fi
if [ -z "$4" ]; then
	echo "Error: Must specify 'rw' or 'ro' as third argument"
	exit 1
fi

if [[ "$(hostname)" != "$NAS_ADMIN_HOST" ]]; then
	echo "Error: Must only run $0 on the NAS admin host"
	exit 1
fi


echo "Creating '$1' ($2:$3, $4)"


#export_seq=$(< /proj/ceph/etc/export_id_seq.txt)
#echo "$(( $export_seq + 1 ))" >| /proj/ceph/etc/export_id_seq.txt
#echo "Export sequence ID: $export_seq"
#echo


#echo "Updating nfs-ganesha config ..."

#cp /etc/mirror_ganesha.conf /etc/mirror_ganesha.conf.last
#cp /proj/ceph/etc/ganesha.conf /etc/mirror_ganesha.conf

mkdir /"$1"
chown "$2":"$3" /"$1"
chmod ug+rwx /"$1"

#cp /proj/ceph/etc/nfs_export.conf.tpl "$export_seq".tmp
tmpfile="$(uuidgen).tmp"
#cp /proj/ceph/etc/nfs_export.tpl.json "$tmpfile"
#sed -i "s|%NEWPATH%|/$1|g" "$tmpfile"
#if [[ "$4" == "rw" ]]; then
#	chmod o+rx /cephfs/"$1"
#	sed -i "s|%ACCESS%|rw|g" "$tmpfile"
#else
#	chmod o= /cephfs/"$1"
#	sed -i "s|%ACCESS%|ro|g" "$tmpfile"
#fi


# Create the NFS export
ceph nfs export create cephfs cephfs-nfs "/$1" cephfs "/$1" --client_addr '10.0.0.0/16' --squash 'root_squash' --sectype sys

# Output the JSON of the export to $tmpfile
ceph nfs export info cephfs-nfs "/$1" | tee "$tmpfile"

# Set the access for the 10.0.0.0/16 subnet to the specified value
#jq '.clients = [{"access_type":"rw","addresses": ["ADMIN1","ADMIN2"],"squash":"none"},{"access_type":"ro","addresses":["10.0.0.0/16"],"squash":"root_squashA"}]' foo
jq "
	.clients = [
		{
			\"access_type\": \"rw\",
			\"addresses\": [\"$ADMIN_IP_1\", \"$ADMIN_IP_2\", \"$ADMIN_IP_3\", \"$NAS_ADMIN_IP\"],
			\"squash\": \"none\"
		},
		{
			\"access_type\": \"$4\",
			\"addresses\": [\"10.0.0.0/16\"],
			\"squash\": \"root_squash\"
		}
	]
" "$tmpfile" | jq ".sec=[\"sys\"]" > "$tmpfile-mod"

# Update the export with the new JSON config
ceph nfs export apply cephfs-nfs -i "$tmpfile-mod"


#cat /etc/mirror_ganesha.conf "$export_seq".tmp > staging.tmp
#mv staging.tmp /etc/mirror_ganesha.conf

#cp /etc/mirror_ganesha.conf /proj/ceph/etc/ganesha.conf

rm "$tmpfile"
rm "$tmpfile-mod"


#echo "Pushing updated nfs-ganesha config ..."

#while read host; do
#	cp /etc/mirror_ganesha.conf "/tmp/$host"
#	sed -i "s/%NODE%/$host/g" "/tmp/$host"
#	scp "/tmp/$host" "$host":/etc/ganesha/ganesha.conf
#	rm "/tmp/$host"
#	echo " ... $host"
#done < /tools/net/etc/linux-ceph-nodes.txt

#echo "Restarting nfs-ganesha on all nodes ..."
#parallel-ssh -h /tools/net/etc/linux-ceph-nodes.txt -l root -i systemctl restart nfs-ganesha

echo "Directory created"

