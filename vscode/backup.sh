#!/bin/bash

backup_proj()
{
	# Clear old backups.
	rm -rf $2
	mkdir $2
	mkdir $2/vscode
		
	# Copy VSCode config.
	cp $1/.vscode/c_cpp_properties.json $2/vscode/c_cpp_properties.json
}

backup_proj "../../visionworkbench/src/vw" "vw"
backup_proj "../../StereoPipeline/src/asp" "StereoPipeline"
backup_proj "../../ISIS3/isis/src" "isis"
