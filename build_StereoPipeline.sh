#!/bin/sh
buildDir=`pwd`/..
installDir=$buildDir/install

pushd $buildDir/StereoPipeline
mkdir -p build
cd build

$HOME/miniconda3/envs/asp_deps/bin/cmake ..                \
  -DASP_DEPS_DIR=$CONDA_PREFIX/envs/asp_deps               \
  -DCMAKE_INSTALL_PREFIX=$installDir                       \
  -DVISIONWORKBENCH_INSTALL_DIR=$installDir                \
  -DISIS_INSTALL_DIR=$installDir                           \
  -DBINARYBUILDER_INSTALL_DIR=$buildDir/BinaryBuilder

make -j`nproc`
make install

popd

