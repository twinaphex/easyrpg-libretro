LOCAL_PATH := $(call my-dir)

CORE_DIR     := $(LOCAL_PATH)/../../..
LIBRETRO_DIR := $(CORE_DIR)/builds/libretro

WANT_LIBICONV := 1

include $(LIBRETRO_DIR)/Makefile.common

COREFLAGS := $(INCDIR) -DUSE_LIBRETRO -DSUPPORT_AUDIO -DWANT_ZLIB -DPIXMAN_NO_TLS -D__STDC_LIMIT_MACROS -D__LIBRETRO__ -DLIBDIR="\"c\""

GIT_VERSION := " $(shell git rev-parse --short HEAD || echo unknown)"
ifneq ($(GIT_VERSION)," unknown")
  COREFLAGS += -DGIT_VERSION=\"$(GIT_VERSION)\"
endif

include $(CLEAR_VARS)
LOCAL_MODULE       := retro
LOCAL_SRC_FILES    := $(SOURCES_CXX) $(SOURCES_C)
LOCAL_CFLAGS       := $(COREFLAGS) 
LOCAL_CXXFLAGS     := $(COREFLAGS) -std=c++11
LOCAL_LDFLAGS      := -Wl,-version-script=$(LIBRETRO_DIR)/link.T
LOCAL_LDLIBS       := -llog
LOCAL_CPP_FEATURES := exceptions
include $(BUILD_SHARED_LIBRARY)
