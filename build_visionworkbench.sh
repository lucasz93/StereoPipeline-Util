#!/bin/sh
buildDir=`pwd`/..
installDir=$buildDir/install

pushd $buildDir/visionworkbench
mkdir -p build
cd build

$HOME/miniconda3/envs/asp_deps/bin/cmake ..                \
  -DASP_DEPS_DIR=$CONDA_PREFIX/envs/asp_deps               \
  -DCMAKE_INSTALL_PREFIX=$installDir

make -j`nproc`
make install

popd

