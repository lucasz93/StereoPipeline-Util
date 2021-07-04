#!/bin/bash

restore_proj()
{	
	# Copy VSCode config.
	cp -r $2/vscode $1/.vscode
}

restore_proj "../../visionworkbench/src/vw" "vw"
restore_proj "../../StereoPipeline/src/asp" "StereoPipeline"
restore_proj "../../ISIS3/isis/src" "isis"
