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
	conda activate build_env
	
	# Also uploads
	conda build -c mechsoft -c conda-forge ../cspice-feedstock/

	conda deactivate

	popd
}

#===============================================================================
#===============================================================================
deploy_spiceypy()
{
	pushd $rootDir/SpiceyPy

	source $HOME/miniconda3/etc/profile.d/conda.sh
	conda activate build_env
	
	# Also uploads
	conda build -c mechsoft -c conda-forge ../spiceypy-feedstock/

	conda deactivate

	popd
}

#===============================================================================
#===============================================================================
deploy_ale()
{
	pushd $rootDir/ale

	source $HOME/miniconda3/etc/profile.d/conda.sh
	conda activate build_env
	
	# Also uploads
	conda build -c mechsoft -c conda-forge ../ale-feedstock/

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
