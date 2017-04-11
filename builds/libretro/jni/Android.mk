LOCAL_PATH := $(call my-dir)
DEBUG = 0
FRONTEND_SUPPORTS_RGB565 = 1

WANT_LIBICONV=1

include $(CLEAR_VARS)

GIT_VERSION := " $(shell git rev-parse --short HEAD || echo unknown)"
ifneq ($(GIT_VERSION)," unknown")
	LOCAL_CXXFLAGS += -DGIT_VERSION=\"$(GIT_VERSION)\"
endif

ifeq ($(TARGET_ARCH),arm)
ANDROID_FLAGS := -DANDROID_ARM
LOCAL_ARM_MODE := arm
endif

ifeq ($(TARGET_ARCH),x86)
ANDROID_FLAGS := -DANDROID_X86
IS_X86 = 1
endif

ifeq ($(TARGET_ARCH),mips)
ANDROID_FLAGS := -DANDROID_MIPS -D__mips__ -D__MIPSEL__
endif

LOCAL_CXXFLAGS += $(ANDROID_FLAGS)
LOCAL_CFLAGS   += $(ANDROID_FLAGS)

CORE_DIR        := ../../..
LOCAL_MODULE    := libretro

CORE_DEFINE := -DUSE_LIBRETRO -DSUPPORT_AUDIO -DWANT_LIBICONV

TARGET_NAME := easyrpg_libretro

include ../Makefile.common
LDFLAGS += -ldl

LOCAL_SRC_FILES += $(SOURCES_CXX) $(SOURCES_C)

ifeq ($(DEBUG),0)
   FLAGS += -O3
else
   FLAGS += -O0 -g
endif

LDFLAGS += $(fpic) $(SHARED)
FLAGS += $(fpic) $(NEW_GCC_FLAGS) $(INCFLAGS)

FLAGS += $(CORE_DEFINE) -D__STDC_LIMIT_MACROS -D__LIBRETRO__ -DNDEBUG $(SOUND_DEFINE)

LOCAL_CFLAGS =  $(FLAGS) 
LOCAL_CXXFLAGS += $(FLAGS) -std=c++11 -fexceptions

EASYRPG_DIR       := $(CORE_DIR)/src
DEPS_DIR          := $(CORE_DIR)/lib
LIBLCF_DIR        := $(DEPS_DIR)/liblcf
PIXMAN_DIR			:= $(DEPS_DIR)/pixman
LIBRETRO_COMM_DIR := $(DEPS_DIR)/libretro-common
LIBICONV_DIR		:= $(DEPS_DIR)/libiconv
LIBPNG_DIR        := $(DEPS_DIR)/libpng
LIBSNDFILE_DIR    := $(DEPS_DIR)/libsndfile
WILDMIDI_DIR		:= $(DEPS_DIR)/wildmidi
TREMOR_DIR        := $(DEPS_DIR)/tremor
LIBSAMPLERATE_DIR := $(DEPS_DIR)/libsamplerate
ZLIB_DIR          := $(DEPS_DIR)/libz

LOCAL_C_INCLUDES = \
						$(CORE_DIR) \
						$(EASYRPG_DIR) \
						$(DEPS_DIR) \
						$(LIBPNG_DIR) \
						$(ZLIB_DIR) \
						$(LIBICONV_DIR)/include \
						$(LIBICONV_DIR)/lib \
						$(LIBLCF_DIR)/src \
						$(PIXMAN_DIR) \
						$(LIBLCF_DIR)/src \
						$(LIBLCF_DIR)/src/generated \
						$(LIBRETRO_COMM_DIR)/include \
						$(LIBRETRO_COMM_DIR)/include/compat

include $(BUILD_SHARED_LIBRARY)
