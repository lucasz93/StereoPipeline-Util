#!/bin/sh
rootDir=`pwd`/..
installDir=$rootDir/install

if [ -z $1 ]; then
	buildType=""
else
	buildType="-DCMAKE_BUILD_TYPE=$1"
fi

echo $buildType
exit 0

pushd $rootDir/ISIS3
mkdir -p build
cd build

$HOME/miniconda3/envs/isis_deps/bin/cmake ../isis           \
  -DJP2KFLAG=OFF                                            \
  -Disis3Data=$ISISDATA                                     \
  -Disis3TestData=$ISISTESTDATA                             \
  -DCMAKE_INSTALL_PREFIX=$installDir                        

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

