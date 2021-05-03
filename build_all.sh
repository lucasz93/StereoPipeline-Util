#!/bin/sh
buildDir=`pwd`/..
installDir=$buildDir/install
cd $buildDir

push_build_dir() {
	pushd $1
	mkdir -p build
	cd build
}

push_build_dir "$buildDir/visionworkbench"
$CONDA_PREFIX/envs/asp_deps/bin/cmake ..                   \
  -DASP_DEPS_DIR=$CONDA_PREFIX/envs/asp_deps               \
  -DCMAKE_VERBOSE_MAKEFILE=ON                              \
  -DCMAKE_INSTALL_PREFIX=$installDir
make -j16
make install
popd



push_build_dir "$buildDir/StereoPipeline"
$CONDA_PREFIX/envs/asp_deps/bin/cmake ..                   \
  -DASP_DEPS_DIR=$CONDA_PREFIX/envs/asp_deps               \
  -DCMAKE_VERBOSE_MAKEFILE=ON                              \
  -DCMAKE_INSTALL_PREFIX=$installDir                       \
  -DVISIONWORKBENCH_INSTALL_DIR=$installDir                \
  -DBINARYBUILDER_INSTALL_DIR=$buildDir/BinaryBuilder
make -j16
make install
popd

