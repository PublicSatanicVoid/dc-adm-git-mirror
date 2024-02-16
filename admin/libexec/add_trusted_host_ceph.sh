#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 IP"
	exit 1
fi

for export_path in $(ceph nfs export ls cephfs-nfs | jq -r '.[]'); do
	echo "Updating: $export_path"
	
	ceph nfs export info cephfs-nfs "$export_path" \
	| jq ".clients = [
		{
			\"access_type\": \"rw\",
			\"addresses\": [
				\"$1\"
			],
			\"squash\": \"none\"
		}
	] + .clients | .sectype = [\"sys\"]" \
	>| tmp.json

	ceph nfs export apply cephfs-nfs -i tmp.json
	if [ $? -ne 0 ]; then
		echo "- Failed ($?)"
	fi

	rm tmp.json
done

