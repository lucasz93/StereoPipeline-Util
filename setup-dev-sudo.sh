#!/bin/bash
set -e

#
# Install all the packages we'll need.
#
sudo apt install build-essential cmake make gcc g++ git tcsh csh parallel lld ccache libgl1-mesa-dev libglu1-mesa-dev ninja-build

#
# Setup the benchmark dir on the NVMe drive.
#
mkdir -p /asp_scratch
chown mechsoft /asp_scratch

mkdir -p /build/glibc-eX1tMB
chown mechsoft /build/glibc-eX1tMB
