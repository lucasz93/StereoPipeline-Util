#!/bin/sh
rootDir=`pwd`/..
installDir=$rootDir/install

if [ -n $1 ]; then
	buildType="-DCMAKE_BUILD_TYPE=$1"
else
	buildType=""
fi

pushd $rootDir/visionworkbench
mkdir -p build
cd build

$HOME/miniconda3/envs/asp_deps/bin/cmake ..                \
  -DASP_DEPS_DIR=$CONDA_PREFIX/envs/asp_deps               \
  -DCMAKE_INSTALL_PREFIX=$installDir                       \
  $buildType

popd

