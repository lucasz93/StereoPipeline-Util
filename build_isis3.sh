#!/bin/sh
rootDir=`pwd`/..
installDir=$rootDir/install

pushd $rootDir/ISIS3/build

export ISISROOT=$(pwd)
export ISISDATA="$HOME/src/install/data"
export ISISTESTDATA="$HOME/src/install/testData"

source $HOME/miniconda3/etc/profile.d/conda.sh
conda activate isis_deps
make install -j `nproc`
conda deactivate

# ISIS installs its headers to /include/isis3, but the conda package is
# distributed in /include/isis. Add a symbolic link so our packages don't break.
if [ ! -f $installDir/include/isis3 ]; then
	mkdir -p $installDir/include/isis3
	ln -s $installDir/include/isis3 $installDir/include/isis
fi

popd

