#!/bin/bash
set -e

buildDir=`pwd`/..
cd $buildDir

checkout_branch()
{
	url=$1
	upstream=$2
	out_dir=$3
	branch=$4

	if [ ! -d $out_dir ]; then
		git clone $url
		pushd $out_dir
		
		if [ ! -z "$upstream" ]; then
			git remote add upstream $upstream
		fi
		
		git checkout $branch
		git submodule update --init --recursive
		
		popd
	fi
	
	if [ ! -z "$upstream" ]; then
		pushd $out_dir
		
		# Some SJW chucklefucks decided the term 'master' was offensive, so now we need to manually detect the master branch name.
		upstream_master_branch_name=`git remote show upstream | sed -n '/HEAD branch/s/.*: //p'`
		origin_branch_name=`git remote show origin | sed -n '/HEAD branch/s/.*: //p'`
		
		git fetch upstream $upstream_master_branch_name:$origin_branch_name --update-head-ok
		git fetch upstream --tags
		git push origin $origin_branch_name
		git push origin --tags
		
		popd
	fi
}

#-------------------------------------------------------------------------------
# NAIF TOOLKIT
#-------------------------------------------------------------------------------
checkout_branch "https://github.com/lucasz93/f2c.git" "https://github.com/barak/f2c" "f2c" "global-state-object"
checkout_branch "https://github.com/lucasz93/naif-toolkit.git" "" "naif-toolkit" "master"
checkout_branch "https://github.com/lucasz93/cspice.git" "" "cspice" "libf2c-multithreading"
checkout_branch "https://github.com/lucasz93/cspice-feedstock.git" "https://github.com/conda-forge/cspice-feedstock" "cspice-feedstock" "dev"

#-------------------------------------------------------------------------------
# CUSTOM COMPILED DEPENDENCIES
#-------------------------------------------------------------------------------
checkout_branch "https://github.com/lucasz93/SpiceyPy.git" "https://github.com/AndrewAnnex/SpiceyPy" "SpiceyPy" "2.3_naif_context"
checkout_branch "https://github.com/lucasz93/spiceypy-feedstock.git" "https://github.com/conda-forge/spiceypy-feedstock" "spiceypy-feedstock" "2.3.2_local"

checkout_branch "https://github.com/lucasz93/ale.git" "https://github.com/USGS-Astrogeology/ale" "ale" "0.8.5-naif_context"
checkout_branch "https://github.com/lucasz93/ale-feedstock.git" "https://github.com/conda-forge/ale-feedstock" "ale-feedstock" "0.8.5-naif_context"

#checkout_branch "https://github.com/lucasz93/isis3_dependencies.git" "https://github.com/chrisryancombs/isis3_dependencies" "isis3_dependencies" "dev"

#-------------------------------------------------------------------------------
# ACTUAL PROGRAMS
#-------------------------------------------------------------------------------
checkout_branch "https://github.com/lucasz93/BinaryBuilder.git" "https://github.com/NeoGeographyToolkit/BinaryBuilder" "BinaryBuilder" "master"
checkout_branch "https://github.com/lucasz93/visionworkbench.git" "https://github.com/visionworkbench/visionworkbench" "visionworkbench" "3.1.0_turbo-camera-forking"
checkout_branch "https://github.com/lucasz93/ISIS3.git" "https://github.com/USGS-Astrogeology/ISIS3" "ISIS3" "6.0.0_turbo-multithreaded-naif"
checkout_branch "https://github.com/lucasz93/StereoPipeline.git" "https://github.com/NeoGeographyToolkit/StereoPipeline" "StereoPipeline" "3.1.0_turbo-camera-forking"

