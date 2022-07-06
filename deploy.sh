#!/bin/bash

#===============================================================================
#===============================================================================
rootDir=`pwd`/..
installDir=$rootDir/install

#===============================================================================
#===============================================================================
deploy_cspice()
{
	pushd $rootDir/cspice

	source $HOME/miniconda3/etc/profile.d/conda.sh
	conda activate dev
	
	conda build -c mechsoft -c conda-forge ../cspice-feedstock/
	anaconda upload $CONDA_PREFIX/conda-bld/linux-64/cspice-66-h7f98852_1014.tar.bz2 --force

	conda deactivate

	popd
}

#===============================================================================
#===============================================================================
deploy_spiceypy()
{
	pushd $rootDir/SpiceyPy

	source $HOME/miniconda3/etc/profile.d/conda.sh
	conda activate dev
	
	conda build -c mechsoft -c conda-forge ../spiceypy-feedstock/
	anaconda upload $CONDA_PREFIX/conda-bld/noarch/spiceypy-2.3.2-py_0.tar.bz2 --force

	conda deactivate

	popd
}

#===============================================================================
#===============================================================================
deploy_ale()
{
	pushd $rootDir/ale

	source $HOME/miniconda3/etc/profile.d/conda.sh
	conda activate dev
	
	conda build -c mechsoft -c conda-forge ../ale-feedstock/
	anaconda upload $CONDA_PREFIX/conda-bld/linux-64/ale-0.8.5-py39h1a9c180_3.tar.bz2 --force
    
	conda deactivate

	popd
}

#===============================================================================
#===============================================================================
for target in "$@"
	do
	case "$target" in
		"spiceypy" ) deploy_spiceypy ;;
		"cspice" ) deploy_cspice ;;
		"ale" ) deploy_ale ;;
		"all" )
			deploy_cspice
			deploy_spiceypy
			deploy_ale
			;;
		* ) 
			echo "deploy: Unknown target '$build_type'"
			echo "./deploy.sh [cspice|spiceypy|ale|all]"
			exit 1
			;;
	esac
done
