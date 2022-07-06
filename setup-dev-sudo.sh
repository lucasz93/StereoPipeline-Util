#!/bin/bash
set -e

#
# Install all the packages we'll need.
#
sudo apt install build-essential cmake make gcc g++ git tcsh csh parallel lld ccache libgl1-mesa-dev libglu1-mesa-dev ninja-build

#
# Setup the benchmark dir on the NVMe drive.
#
mkdir /asp_scratch
chown mechsoft /asp_scratch

