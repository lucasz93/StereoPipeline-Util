#!/bin/bash

mode=$1

if [ "$mode" != "backup" ] && [ "$mode" != "restore" ]; then
	echo "./config.sh [backup|restore]"
	exit 1
fi

do_proj()
{
	src=$1
	dst=$2

	# Swap src and dst if restoring.
	if [ "$mode" == "restore" ]; then
		tmp=$src
		src=$dst
		dst=$tmp
	fi

	# Clear old backups.
	rm -rf $dst/.vscode
	mkdir -p $dst/.vscode
	
	# Copy VSCode config.
	cp $src/.vscode/* $dst/.vscode
}

do_proj "../../visionworkbench/src/vw" "vw"
do_proj "../../StereoPipeline/src/asp" "StereoPipeline"
do_proj "../../ISIS3/isis/src" "isis"
do_proj "../../f2c/src" "f2c"
do_proj "../../ale/src" "ale"
