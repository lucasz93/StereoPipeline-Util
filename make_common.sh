#===============================================================================
#===============================================================================
rootDir=`pwd`/..
installDir=$rootDir/install

#===============================================================================
#===============================================================================
make_visionworkbench()
{
	pushd $rootDir/visionworkbench/build

	ninja $1 -j `nproc`

	popd
}

#===============================================================================
#===============================================================================
make_isis3()
{
	pushd $rootDir/ISIS3/build

	export ISISROOT=$(pwd)
	export ISISDATA="$HOME/src/install/data"
	export ISISTESTDATA="$HOME/src/install/testData"

	source $HOME/miniconda3/etc/profile.d/conda.sh
	conda activate isis_deps
	ninja $1 -j `nproc`
	conda deactivate

	# ISIS installs its headers to /include/isis3, but the conda package is
	# distributed in /include/isis. Add a symbolic link so our packages don't break.
	if [ ! -f $installDir/include/isis3 ]; then
		mkdir -p $installDir/include/isis3
	fi
	if [ ! -L $installDir/include/isis ]; then
		ln -s $installDir/include/isis3 $installDir/include/isis
	fi

	popd
}

#===============================================================================
#===============================================================================
make_stereopipeline()
{
	pushd $rootDir/StereoPipeline/build

	ninja $1 -j `nproc`

	popd
}

#===============================================================================
# $1 = script name
# $2 = target
# $3 = directive
#===============================================================================
make_project()
{
	if [ -z $2 ]; then
		echo "./$1.sh [all|isis|asp|vw]"
		exit 1
	fi

	case "$2" in
		"vw" ) make_visionworkbench "$3" ;;
		"isis" ) make_isis3 "$3" ;;
		"asp" ) make_stereopipeline "$3" ;;
		"all" )
			# Order is significant.
			make_visionworkbench "$3"
			make_isis3 "$3"
			make_stereopipeline "$3"
			;;
		* ) 
			echo "$1: Unknown target '$2'"
			exit 1
			;;
	esac
}

