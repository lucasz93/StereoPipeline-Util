#!/bin/sh
rootDir=`pwd`/..
installDir=$rootDir/install

if [ -z $1 ]; then
	buildType=""
else
	buildType="-DCMAKE_BUILD_TYPE=$1"
fi

pushd $rootDir/visionworkbench
mkdir -p build
cd build

$HOME/miniconda3/envs/asp_deps/bin/cmake ..                \
  -DASP_DEPS_DIR=$CONDA_PREFIX/envs/asp_deps               \
  -DCMAKE_INSTALL_PREFIX=$installDir                       \
  $buildType

popd

