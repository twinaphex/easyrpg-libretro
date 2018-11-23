#!/bin/bash

for abi in armeabi armeabi-v7a x86 arm64-v8a;do
	mkdir -p android_$abi/libretro/lib
for x in libz libpng libpixman-1 libfreetype libxmp-lite libsndfile \
	libsamplerate libmpg123 libogg libvorbis libvorbisfile libexpat \
	libWildMidi libicui18n libicuuc libicudata liblcf easyrpg_libretro;do
	touch android_$abi/libretro/lib/$x.a
done
done
