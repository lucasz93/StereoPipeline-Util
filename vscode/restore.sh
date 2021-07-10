#!/bin/bash

restore_proj()
{
	mkdir $1/.vscode

	# Copy VSCode config.
	cp $2/vscode/c_cpp_properties.json $1/.vscode/c_cpp_properties.json
}

restore_proj "../../visionworkbench/src/vw" "vw"
restore_proj "../../StereoPipeline/src/asp" "StereoPipeline"
restore_proj "../../ISIS3/isis/src" "isis"
