#!/bin/sh
rootDir=`pwd`/..

pushd $rootDir/StereoPipeline/build

make install -j `nproc`

popd

