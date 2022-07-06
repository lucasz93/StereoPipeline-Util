#!/bin/bash
set -e

SCRIPT_HOME=`pwd`

#
# Setup ccache.
#
mkdir -p /ccache
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
	pushd ~/Downloads
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
	bash Miniconda3-latest-Linux-x86_64.sh -b
	eval "$(/home/mechsoft/miniconda3/bin/conda shell.bash hook)"
	conda init
	popd
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
conda install conda-build anaconda-client -y
pip install jinja2 
# Not needed now that we just do local builds.
anaconda login 
conda deactivate 

#
# Checkout all source code.
#
cd $SCRIPT_HOME
bash checkout.sh

#
# Setup benchmarking dir.
#
cd /asp_scratch
cp -r /mechsrc/nasa/StereoPipeline/examples/* /asp_scratch
ln -f /mechsrc/nasa/asp-util/timing/time_mro_ctx.sh CTX/time_mro_ctx.sh

#
# Install VSCode.
#
snap install --classic code

#
# Setup ISIS build environment.
#
conda env create -f $SCRIPT_HOME/../ISIS3/environment.yml -n isis_deps --quiet

#
# Setup ASP build environment.
#
conda env create -f $SCRIPT_HOME/../StereoPipeline/conda/asp_deps_2.7.0_linux_env.yaml --quiet
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
cd $SCRIPT_HOME
bash init.cmd Debug
