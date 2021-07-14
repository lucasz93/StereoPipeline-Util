#!/bin/bash

#===============================================================================
#===============================================================================
rootDir=`pwd`/..
installDir=$rootDir/install

build_type=$1
shift

case build_type in
	"Debug" ) ;&
	"MinSizeRel" ) ;&
	"RelWithDebInfo" ) ;&
	"Release" )
		buildType="-DCMAKE_BUILD_TYPE=build_type"
		;;
	* )
		buildType=""
		;;
esac

#===============================================================================
#===============================================================================
configure_visionworkbench()
{
	pushd $rootDir/visionworkbench
	mkdir -p build
	cd build

	$HOME/miniconda3/envs/asp_deps/bin/cmake .. -GNinja        \
	  -DASP_DEPS_DIR=$CONDA_PREFIX/envs/asp_deps               \
	  -DCMAKE_INSTALL_MESSAGE=LAZY                             \
	  -DCMAKE_INSTALL_PREFIX=$installDir                       \
	  $buildType

	popd
}

#===============================================================================
#===============================================================================
configure_isis3()
{
	pushd $rootDir/ISIS3
	mkdir -p build
	cd build

	$HOME/miniconda3/envs/isis_deps/bin/cmake ../isis -GNinja   \
	  -DJP2KFLAG=OFF                                            \
	  -Disis3Data=$ISISDATA                                     \
	  -Disis3TestData=$ISISTESTDATA                             \
	  -DCMAKE_INSTALL_MESSAGE=LAZY                              \
	  -DCMAKE_INSTALL_PREFIX=$installDir                        \
	  -DOVERRIDE_CSPICE_INCLUDE_DIR=$installDir/include         \
	  -DOVERRIDE_CSPICE_LIB_DIR=$installDir/lib                 \
	  $buildType                        

	# Ensure the install dir exists.
	if [ ! -f $installDir ]; then
		mkdir -p $installDir
	fi

	# Setup links to the data sets.
	if [ ! -L $installDir/data ]; then
		ln -s $HOME/data $installDir/data
	fi
	if [ ! -L $installDir/testData ]; then
		ln -s $HOME/testData $installDir/testData
	fi

	popd
}

#===============================================================================
#===============================================================================
configure_stereopipeline()
{
	pushd $rootDir/StereoPipeline
	mkdir -p build
	cd build

	$HOME/miniconda3/envs/asp_deps/bin/cmake .. -GNinja        \
	  -DASP_DEPS_DIR=$CONDA_PREFIX/envs/asp_deps               \
	  -DVISIONWORKBENCH_INSTALL_DIR=$installDir                \
	  -DISIS_INSTALL_DIR=$installDir                           \
 	  -DCSPICE_INSTALL_DIR=$installDir                         \
	  -DBINARYBUILDER_INSTALL_DIR=$rootDir/BinaryBuilder       \
	  -DCMAKE_INSTALL_MESSAGE=LAZY                             \
	  -DCMAKE_INSTALL_PREFIX=$installDir                       \
	  $buildType

	popd
}

#===============================================================================
#===============================================================================
configure_f2c()
{
	pushd $rootDir/f2c
	mkdir -p build
	cd build

	$HOME/miniconda3/envs/asp_deps/bin/cmake .. -GNinja        \
	  -DCMAKE_INSTALL_MESSAGE=LAZY                             \
	  -DCMAKE_INSTALL_PREFIX=$installDir                       \
	  $buildType

	popd
}

#===============================================================================
#===============================================================================
if [ -z $1 ]; then
	echo "./configure.sh [f2c|vw|isis|asp|all]"
	exit 1
fi

for target in "$@"
	do
	case "$target" in
		"f2c" ) configure_f2c "build_type" ;;
		"vw" ) configure_visionworkbench "build_type" ;;
		"isis" ) configure_isis3 "build_type" ;;
		"asp" ) configure_stereopipeline "build_type" ;;
		"all" )
			configure_f2c "build_type"
			
			configure_visionworkbench "build_type"
			configure_isis3 "build_type"
			configure_stereopipeline "build_type"
			;;
		* ) 
			echo "configure: Unknown target 'build_type'"
			exit 1
			;;
	esac
done
