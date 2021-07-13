#!/bin/bash
#
# StereoPipeline config fails if it can't find the visionworkbench or ISIS binaries.
# So this script configures and builds everything in the right order.
# After running this script we can run configures and builds in any order.
#

case $1 in
	"Debug" ) ;;
	"MinSizeRel" ) ;;
	"RelWithDebInfo" ) ;;
	"Release" ) ;;
	* )
		echo "./init.sh [Debug|MinSizeRel|RelWithDebInfo|Release]"
		exit 1
		;;
esac

bash checkout.sh

bash configure.sh $1 vw
bash make_install.sh vw

# Building ISIS is a 2 pass process, for some reason.
# I think the first configure & build populates build/inc, which allows the second configure to properly generate the install script.
bash configure.sh $1 isis
bash make.sh isis
bash configure.sh $1 isis
bash make_install.sh isis

bash configure.sh $1 asp
bash make_install.sh asp

# Setup VSCode.
pushd vscode
bash config.sh restore
popd
