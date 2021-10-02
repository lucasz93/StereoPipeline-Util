#!/bin/bash
set -e

#
# Install all the packages we'll need.
#
apt install build-essential cmake make gcc g++ git tcsh csh parallel lld ccache libgl1-mesa-dev libglu1-mesa-dev ninja-build

#
# Setup ccache.
#
mkdir /ccache
chown mechsoft /ccache
ccache -M 25G

#
# Setup ISIS and ASP variables.
# Do this before installing miniconda - miniconda also modifies ~/.bashrc.
#
cat env/asp >> ~/.bashrc

#
# Install miniconda.
#
if [ ! -d "$HOME/miniconda3" ]; then
	cd ~/Downloads
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
	bash Miniconda3-latest-Linux-x86_64.sh -b
	eval "$(/home/mechsoft/miniconda3/bin/conda shell.bash hook)"
	conda init
else
	source $HOME/miniconda3/etc/profile.d/conda.sh
fi

#
# Setup dev environment.
# Used by cspice, ale and spiceypy in make_common.sh
#
conda create --name dev -y
conda activate dev 
conda config --add channels conda-forge 
conda install conda-build -y
pip install jinja2 
# Not needed now that we just do local builds.
#anaconda login 
conda deactivate 

#
# Checkout all source code.
#
bash checkout.sh

#
# Setup benchmarking dir.
#
mkdir /asp_scratch
chown mechsoft /asp_scratch
cd /asp_scratch
cp -r /mechsrc/nasa/StereoPipeline/examples/* /asp_scratch
ln /mechsrc/nasa/asp-util/timing/time_mro_ctx.sh CTX/time_mro_ctx.sh

#
# Install VSCode.
#
snap install --classic code

#
# Setup ISIS build environment.
#
conda env create -n isis_deps -f ../ISIS3/environment.yml --quiet

#
# Setup ASP build environment.
#
conda env create -f ../StereoPipeline/conda/asp_deps_2.7.0_linux_env.yaml --quiet
conda activate asp_deps
pushd ~/miniconda3/envs/asp_deps/lib
mkdir -p  backup
cp -fv  *.la backup # back these up
perl -pi -e "s#(/[^\s]*?lib)/lib([^\s]+).la#-L\$1 -l\$2#g" *.la
popd
conda deactivate

#
# Create the glibc debug stuff.
#
mkdir -p /build/glibc-eX1tMB
pushd /build/glibc-eX1tMB
wget http://mirror.lagoon.nc/gnu/libc/glibc-2.31.tar.bz2
tar -xvjf glibc-2.31.tar.bz2

#
# Build everything.
#
bash init.cmd Debug
