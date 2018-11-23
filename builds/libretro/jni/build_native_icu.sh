#!/bin/bash

set -e

# Number of CPU
if [ "$(uname)" == "Darwin" ]; then
	nproc=$(getconf _NPROCESSORS_ONLN)
else
	nproc=$(nproc)
fi

export MAKEFLAGS="-j${nproc:-4}"
ICU_PATH=$PWD/../deps/libretro

rm -rf $ICU_PATH/icu-native
cp -r $ICU_PATH/icu $ICU_PATH/icu-native

source $PWD/../deps/shared/common.sh
source $PWD/../deps/shared/packages.sh

cd $ICU_PATH

install_lib_icu_native
