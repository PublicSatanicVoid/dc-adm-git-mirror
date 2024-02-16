#!/bin/bash

if [ -z "$4" ]; then
	echo "usage: $0 <basedir> <blocksize> <blockcount> <threadcount>"
	exit 1
fi

dir="$1/stress"
mkdir -p "$dir"

if [[ $5 == "--worker" ]]; then
	dd if=/dev/zero of="$dir/$$" bs=$2 count=$3
else

	for i in $(seq 1 $4); do
		$0 $1 $2 $3 $4 --worker &
	done

	wait

	rm -rf "$dir"
fi
