#!/bin/bash
set -e

buildDir=`pwd`/..
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
checkout_branch "https://github.com/lucasz93/f2c.git" "f2c" "global-state-object"
checkout_branch "https://github.com/lucasz93/naif-toolkit.git" "naif-toolkit" "master"
checkout_branch "https://github.com/lucasz93/cspice.git" "cspice" "libf2c-multithreading"
checkout_branch "https://github.com/lucasz93/cspice-feedstock.git" "cspice-feedstock" "dev"

#-------------------------------------------------------------------------------
# CUSTOM COMPILED DEPENDENCIES
#-------------------------------------------------------------------------------
checkout_branch "https://github.com/lucasz93/SpiceyPy.git" "SpiceyPy" "2.3_naif_context"
checkout_branch "https://github.com/lucasz93/spiceypy-feedstock.git" "spiceypy-feedstock" "2.3.2_local"

checkout_branch "https://github.com/lucasz93/ale.git" "ale" "0.8.5-naif_context"
checkout_branch "https://github.com/lucasz93/ale-feedstock.git" "ale-feedstock" "0.8.5-naif_context"

checkout_branch "https://github.com/lucasz93/isis3_dependencies.git" "isis3_dependencies" "dev"

#-------------------------------------------------------------------------------
# ACTUAL PROGRAMS
#-------------------------------------------------------------------------------
checkout_branch "https://github.com/lucasz93/BinaryBuilder.git" "BinaryBuilder" "master"
checkout_branch "https://github.com/lucasz93/visionworkbench.git" "visionworkbench" "2.7.0_turbo-camera-forking"
checkout_branch "https://github.com/lucasz93/ISIS3.git" "ISIS3" "4.1_turbo-multithreaded-naif"
checkout_branch "https://github.com/lucasz93/StereoPipeline.git" "StereoPipeline" "2.7.0_turbo-camera-forking"

