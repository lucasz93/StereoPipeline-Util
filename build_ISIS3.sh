#!/bin/sh
buildDir=`pwd`/..
installDir=$buildDir/install

pushd $buildDir/ISIS3
mkdir -p build install
cd build

export ISISROOT=$(pwd)
export ISISDATA="$HOME/src/install/data"
export ISISTESTDATA="$HOME/src/install/testData"

$HOME/miniconda3/envs/isis_deps/bin/cmake ../isis           \
  -DJP2KFLAG=OFF                                            \
  -Disis3Data=$ISISDATA                                     \
  -Disis3TestData=$ISISTESTDATA                             \
  -DCMAKE_INSTALL_PREFIX=$installDir

source $HOME/miniconda3/etc/profile.d/conda.sh
conda activate isis_deps
make -j`nproc`
make install
conda deactivate

# ISIS installs its headers to /include/isis3, but the conda package is
# distributed in /include/isis. Add a symbolic link so our packages don't break.
ln -s $installDir/include/isis3 $installDir/include/isis

popd

