#!/bin/bash

if [ $# -ne 2 ]; then
	echo "./build_nvptx_gcc [work_dir] [install_dir]"
	exit
fi;

#
# Build GCC with support for offloading to NVIDIA GPUs.
#

work_dir=$1
install_dir=$2
accelerator=nvptx-none

# Need access to our custom compiler and binutils
export PATH="$install_dir/bin:$PATH"

# Location of the installed CUDA toolkit
cuda=/usr/local/cuda

#
# Build assembler and linking tools
#
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

#
# Set up the GCC source tree
#
git clone git://sourceware.org/git/newlib-cygwin.git nvptx-newlib
git clone --branch releases/gcc-11 git://gcc.gnu.org/git/gcc.git gcc
cd gcc
contrib/download_prerequisites
ln -s ../nvptx-newlib/newlib newlib
cd ..
target=$(gcc/config.guess)

#
# Build cross compiler. Used for libraries that need to run on target.
#
mkdir build-nvptx-gcc
cd build-nvptx-gcc
../gcc/configure \
    --target=$accelerator --with-build-time-tools=$install_dir/$accelerator/bin \
    --without-headers \
    --with-newlib \
    --disable-multilib \
    --disable-sjlj-exceptions \
    --enable-newlib-io-long-long \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j`nproc` all-gcc || exit 1
make install-gcc || exit 1
cd ..

#
# Build newlib
#
mkdir build-newlib
cd build-newlib
../nvptx-newlib/configure --target=$accelerator --prefix=$install_dir
make -j`nproc` all
make install
cd ..

#
# Build cross compiler with newlib support.
#
cd build-nvptx-gcc
../gcc/configure \
    --target=$accelerator --with-build-time-tools=$install_dir/$accelerator/bin \
    --with-newlib \
#    --disable-shared \
    --disable-libssp \
    --disable-multilib \
    --disable-sjlj-exceptions \
    --enable-newlib-io-long-long \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j`nproc` all
make install
cd ..

#
# Build acceleration compiler.
#
mkdir build-nvptx-gcc-accel
cd build-nvptx-gcc-accel
../gcc/configure \
    --target=$accelerator --with-build-time-tools=$install_dir/$accelerator/bin \
    --enable-as-accelerator-for=$target \
    --disable-sjlj-exceptions \
    --enable-newlib-io-long-long \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j`nproc` || exit 1
make install || exit 1
cd ..

#
# Build host GCC
#
mkdir build-host-gcc
cd  build-host-gcc
../gcc/configure \
    --enable-offload-targets=$accelerator \
    --with-cuda-driver-include=$cuda/include \
    --with-cuda-driver-lib=$cuda/lib64 \
    --disable-bootstrap \
    --disable-multilib \
    --enable-languages="c,c++,fortran,lto" \
    --prefix=$install_dir
make -j`nproc` || exit 1
make install || exit 1
cd ..
