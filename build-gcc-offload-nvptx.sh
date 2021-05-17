#!/bin/sh

#
# Build GCC with support for offloading to NVIDIA GPUs.
#

work_dir=$HOME/offload/wrk
install_dir=$HOME/offload/install

# Location of the installed CUDA toolkit
cuda=/usr/local/cuda

# Build assembler and linking tools
mkdir -p $work_dir
cd $work_dir
git clone https://github.com/MentorEmbedded/nvptx-tools
cd nvptx-tools
./configure \
    --with-cuda-driver-include=$cuda/include \
    --with-cuda-driver-lib=$cuda/lib64 \
    --prefix=$install_dir
make -j`nproc` || exit 1
make install || exit 1
cd ..

# Set up the GCC source tree
git clone git://sourceware.org/git/newlib-cygwin.git nvptx-newlib
git clone --branch releases/gcc-11 git://gcc.gnu.org/git/gcc.git gcc
cd gcc
contrib/download_prerequisites
ln -s ../nvptx-newlib/newlib newlib
cd ..
target=$(gcc/config.guess)

# Build nvptx GCC
# TODO: Build the support libraries as well - https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
# https://gcc.gnu.org/wiki/Offloading
mkdir build-nvptx-gcc-accel
cd build-nvptx-gcc-accel
../gcc/configure \
    --target=nvptx-none --with-build-time-tools=$install_dir/nvptx-none/bin \
    --enable-as-accelerator-for=$target \
    --disable-sjlj-exceptions \
    --enable-newlib-io-long-long \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j`nproc` || exit 1
make install || exit 1
cd ..

mkdir build-nvptx-gcc
cd build-nvptx-gcc
../gcc/configure \
    --target=nvptx-none --with-build-time-tools=$install_dir/nvptx-none/bin \
    --disable-sjlj-exceptions \
    --enable-newlib-io-long-long \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j`nproc` || exit 1
make install || exit 1
cd ..

# Build host GCC
mkdir build-host-gcc
cd  build-host-gcc
../gcc/configure \
    --enable-offload-targets=nvptx-none \
    --with-cuda-driver-include=$cuda/include \
    --with-cuda-driver-lib=$cuda/lib64 \
    --disable-bootstrap \
    --disable-multilib \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j`nproc` || exit 1
make install || exit 1
cd ..
