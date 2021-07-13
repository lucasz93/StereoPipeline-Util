#!/bin/sh

#===============================================================================
#===============================================================================
rootDir=`pwd`/..
installDir=$rootDir/install

case $2 in
	"Debug" ) ;&
	"MinSizeRel" ) ;&
	"RelWithDebInfo" ) ;&
	"Release" )
		buildType="-DCMAKE_BUILD_TYPE=$2"
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
	  -DBINARYBUILDER_INSTALL_DIR=$rootDir/BinaryBuilder       \
	  -DCMAKE_INSTALL_MESSAGE=LAZY                             \
	  -DCMAKE_INSTALL_PREFIX=$installDir                       \
	  $buildType

	popd
}

#===============================================================================
#===============================================================================
if [ -z $1 ]; then
	echo "./configure.sh [isis|asp|vw]"
	exit 1
fi

case "$1" in
	"isis" ) configure_isis3 "$2" ;;
	"asp" ) configure_stereopipeline "$2" ;;
	"vw" ) configure_visionworkbench "$2" ;;
	"all" ) 
		configure_visionworkbench "$2"
		configure_isis3 "$2"
		configure_stereopipeline "$2"
		;;
	* ) 
		echo "configure: Unknown target '$2'"
		exit 1
		;;
esac
