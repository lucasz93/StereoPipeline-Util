#!/bin/sh
buildDir=`pwd`/..
installDir=$buildDir/install

pushd $buildDir/ISIS3
mkdir -p build install
cd build

export ISISROOT=$(pwd)
export ISISDATA="$HOME/miniconda3/envs/isis/data"
export ISISTESTDATA="$HOME/miniconda3/envs/isis/testData"

$HOME/miniconda3/envs/asp_deps/bin/cmake ../isis            \
  -DJP2KFLAG=OFF                                            \
  -Disis3Data=$HOME/miniconda3/envs/isis/data               \
  -Disis3TestData=$HOME/miniconda3/envs/isis/testData       \
#  -DCMAKE_VERBOSE_MAKEFILE=ON                               \
  -DCMAKE_INSTALL_PREFIX=$installDir

source $HOME/miniconda3/etc/profile.d/conda.sh
conda activate isis_deps
make -j`nproc`
make install
conda deactivate

popd

