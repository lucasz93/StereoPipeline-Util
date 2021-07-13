#!/bin/bash

source ./make_common.sh

for target in "$@"
do
	make_project "make" "$target" ""
done

