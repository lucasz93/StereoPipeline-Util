#!/bin/sh
buildDir=`pwd`/..
installDir=$buildDir/install
cd $buildDir

checkout_branch()
{
	url=$1
	out_dir=$2
	branch=$3

	if [ ! -d $2 ]; then
		git clone $url
		pushd $out_dir
			git checkout $branch
			git submodule update --init --recursive
		popd
	fi
}

#-------------------------------------------------------------------------------
# NAIF TOOLKIT
#-------------------------------------------------------------------------------
checkout_branch "https://github.com/lucasz93/f2c.git" "f2c" "naif_tls"
checkout_branch "https://github.com/lucasz93/naif-toolkit.git" "naif-toolkit" "master"
checkout_branch "https://github.com/lucasz93/cspice.git" "cspice" "dev"
checkout_branch "https://github.com/lucasz93/cspice-feedstock.git" "cspice-feedstock" "dev"

#-------------------------------------------------------------------------------
# ACTUAL PROGRAMS
#-------------------------------------------------------------------------------
checkout_branch "https://github.com/lucasz93/BinaryBuilder.git" "BinaryBuilder" "master"
checkout_branch "https://github.com/lucasz93/visionworkbench.git" "visionworkbench" "2.7.0_turbo"
checkout_branch "https://github.com/lucasz93/ISIS3.git" "ISIS3" "4.1_turbo"
checkout_branch "https://github.com/lucasz93/StereoPipeline.git" "StereoPipeline" "2.7.0_turbo"

