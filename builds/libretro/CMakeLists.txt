cmake_minimum_required(VERSION 3.7)

project(retro_common VERSION 1.0 LANGUAGES C)

add_library(retro_common STATIC
	libretro-common/rthreads/rthreads.c
)

target_include_directories(retro_common PUBLIC
	libretro-common/include)

# FIXME: Likely won't work on all platforms
target_link_libraries(retro_common "pthread")
