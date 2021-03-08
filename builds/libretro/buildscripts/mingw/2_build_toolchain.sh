#!/bin/bash

# abort on errors
set -e

export WORKSPACE=$PWD

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/../shared/import.sh
# Override ICU version to 67.1
source $SCRIPT_DIR/packages.sh

# Number of CPU
nproc=$(nproc)

# Use ccache?
test_ccache

if [ ! -f .patches-applied ]; then
	echo "Patching libraries"

	patches_common

	(cd $ZLIB_DIR
		perl -pi -e 's/        leave 1//' configure
	)

	cp -rup icu icu-native

	(cd icu
	patch -Np1 < ../mingw-w64-icu/0011-sbin-dir.mingw.patch
	patch -Np1 < ../mingw-w64-icu/0012-libprefix.mingw.patch
	patch -Np1 < ../mingw-w64-icu/0014-mingwize-pkgdata.mingw.patch
	patch -Np1 < ../mingw-w64-icu/0015-debug.mingw.patch
	patch -Np1 < ../mingw-w64-icu/0016-icu-pkgconfig.patch
	patch -Np1 < ../mingw-w64-icu/0017-icu-config-versioning.patch
	patch -Np1 < ../mingw-w64-icu/0021-mingw-static-libraries-without-s.patch
	patch -Np1 < ../mingw-w64-icu/0023-fix-twice-include-platform_make_fragment.patch
	)

	touch .patches-applied
fi

cd $WORKSPACE

echo "Preparing toolchain"

export PLATFORM_PREFIX=$WORKSPACE
export PKG_CONFIG=/usr/bin/pkg-config
export PKG_CONFIG_LIBDIR=$PLATFORM_PREFIX/lib/pkgconfig
unset PKG_CONFIG_PATH
export MAKEFLAGS="-j${nproc:-2}"
export TOOLCHAIN_FILE="-DCMAKE_TOOLCHAIN_FILE=$PWD/mingw-w64-x86_64.cmake"

function set_build_flags {
	export CC="$TARGET_HOST-gcc"
	export CXX="$TARGET_HOST-g++"
	if [ "$ENABLE_CCACHE" ]; then
		export CC="ccache $CC"
		export CXX="ccache $CXX"
	fi
	export CFLAGS="-g0 -O2"
	export CXXFLAGS=$CFLAGS
	export CPPFLAGS="-I$PLATFORM_PREFIX/include"
	export LDFLAGS="-L$PLATFORM_PREFIX/lib"
}

install_lib_icu_native

set_build_flags
install_lib_zlib
install_lib $LIBPNG_DIR $LIBPNG_ARGS
install_lib $FREETYPE_DIR $FREETYPE_ARGS --without-harfbuzz
install_lib $HARFBUZZ_DIR $HARFBUZZ_ARGS
install_lib $FREETYPE_DIR $FREETYPE_ARGS --with-harfbuzz
install_lib $PIXMAN_DIR $PIXMAN_ARGS
install_lib_cmake $EXPAT_DIR $EXPAT_ARGS $TOOLCHAIN_FILE
install_lib $LIBOGG_DIR $LIBOGG_ARGS
install_lib $LIBVORBIS_DIR $LIBVORBIS_ARGS
install_lib_mpg123
install_lib $LIBSNDFILE_DIR $LIBSNDFILE_ARGS
#install_lib_cmake $LIBXMP_LITE_DIR $LIBXMP_LITE_ARGS $TOOLCHAIN_FILE
install_lib $SPEEXDSP_DIR $SPEEXDSP_ARGS
install_lib_cmake $WILDMIDI_DIR $WILDMIDI_ARGS $TOOLCHAIN_FILE
install_lib_cmake $FLUIDLITE_DIR $FLUIDLITE_ARGS -DENABLE_SF3=ON $TOOLCHAIN_FILE
install_lib $OPUS_DIR $OPUS_ARGS
install_lib $OPUSFILE_DIR $OPUSFILE_ARGS
install_lib_cmake $FMT_DIR $FMT_ARGS $TOOLCHAIN_FILE
install_lib_icu_cross

# ICU: Force datafile build
echo "ICU: Force Build data file"

export PKGDATA_OPTS="-w -v -O $PWD/icu/source/config/pkgdata.inc"

(cd icu/source/data
	make clean
	make
)

cp icu/source/lib/libicudt.a lib/

