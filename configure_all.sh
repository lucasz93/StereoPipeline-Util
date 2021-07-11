#!/bin/sh

if [ -n $1 ]; then
	buildType="$1"
else
	buildType=Release
fi

bash ./configure_visionworkbench.sh $buildType
bash ./configure_isis3.sh $buildType
bash ./configure_stereopipeline.sh $buildType
