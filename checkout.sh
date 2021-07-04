#!/bin/sh
buildDir=`pwd`/..
installDir=$buildDir/install
cd $buildDir

$CONDA_PREFIX/envs/asp_deps/bin/git clone                  \
    https://github.com/lucasz93/visionworkbench.git
pushd visionworkbench
git checkout 2.7.0_omp
git submodule update --init --recursive
popd


$CONDA_PREFIX/envs/asp_deps/bin/git clone                  \
https://github.com/lucasz93/BinaryBuilder.git


$CONDA_PREFIX/envs/asp_deps/bin/git clone                  \
https://github.com/lucasz93/ISIS3.git
pushd ISIS3
git checkout 4.4_omp
git submodule update --init --recursive
popd

$CONDA_PREFIX/envs/asp_deps/bin/git clone                  \
https://github.com/lucasz93/StereoPipeline.git
pushd StereoPipeline
git checkout 2.7.0_omp
git submodule update --init --recursive
popd

