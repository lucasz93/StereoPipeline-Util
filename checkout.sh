#!/bin/sh
buildDir=`pwd`/..
installDir=$buildDir/install
cd $buildDir

#-------------------------------------------------------------------------------
# NAIF TOOLKIT
#-------------------------------------------------------------------------------
git clone https://github.com/lucasz93/f2c.git
pushd f2c
git checkout naif_tls
popd

git clone https://github.com/lucasz93/naif-toolkit.git
git clone https://github.com/lucasz93/naif-cspice.git

#-------------------------------------------------------------------------------
# ACTUAL PROGRAMS
#-------------------------------------------------------------------------------
git clone https://github.com/lucasz93/BinaryBuilder.git


git clone https://github.com/lucasz93/visionworkbench.git
pushd visionworkbench
git checkout 2.7.0_turbo
git submodule update --init --recursive
popd


git clone https://github.com/lucasz93/ISIS3.git
pushd ISIS3
git checkout 4.1_turbo
git submodule update --init --recursive
popd


git clone https://github.com/lucasz93/StereoPipeline.git
pushd StereoPipeline
git checkout 2.7.0_turbo
git submodule update --init --recursive
popd

