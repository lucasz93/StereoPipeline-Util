#!/bin/sh
#
# StereoPipeline config fails if it can't find the visionworkbench or ISIS binaries.
# So this script configures and builds everything in the right order.
# After running this script we can run configures and builds in any order.
#

bash checkout.sh

bash configure_visionworkbench.sh $1
bash build_visionworkbench.sh

# Building ISIS is a 2 pass process, for some reason.
# I think the first configure & build populates build/inc, which allows the second configure to properly generate the install script.
bash configure_isis3.sh $1
bash build_isis3.sh
bash configure_isis3.sh $1
bash build_isis3.sh

bash configure_stereopipeline.sh $1
bash build_stereopipeline.sh

# Setup VSCode.
pushd vscode
bash config.sh restore
popd
