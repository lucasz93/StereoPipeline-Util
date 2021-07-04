#!/bin/bash

backup_proj()
{
	# Clear old backups.
	rm -rf $2
	mkdir $2
	
	# Copy VSCode config.
	cp -r $1/.vscode $2/vscode
}

backup_proj "../../visionworkbench/src/vw" "vw"
backup_proj "../../StereoPipeline/src/asp" "StereoPipeline"
backup_proj "../../ISIS3/isis/src" "isis"
