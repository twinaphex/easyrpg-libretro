CORE_DIR     := $(LOCAL_PATH)/../../..
DEPS_DIR$(TARGET_ARCH_ABI) := $(CORE_DIR)/builds/libretro/jni/android_$(TARGET_ARCH_ABI)

GIT_VERSION := $(shell git rev-parse --short HEAD || echo unknown)
ifneq ($(GIT_VERSION)," unknown")
	COREFLAGS += -DGIT_VERSION=$(GIT_VERSION)
endif

COMMON_DEFINES := \
		-DUSE_LIBRETRO \
		-DHAVE_MPG123 -DWANT_FMMIDI -DHAVE_WILDMIDI \
		-DHAVE_OGGVORBIS -DHAVE_LIBSNDFILE \
		-DHAVE_LIBSAMPLERATE -DSUPPORT_AUDIO

COREFLAGS += $(COMMON_DEFINES)

include $(CLEAR_VARS)
LOCAL_MODULE       := retro
LOCAL_SRC_FILES    := \
	src/main.cpp \
	src/build_deps_$(TARGET_ARCH_ABI).cpp \
	$(CORE_DIR)/builds/libretro/libretro-common/rthreads/rthreads.c
LOCAL_CFLAGS       := $(COREFLAGS) -I$(CORE_DIR)/builds/libretro/libretro-common/include
LOCAL_CXXFLAGS     := $(COREFLAGS) -std=c++11
LOCAL_STATIC_LIBRARIES += easyrpg_libretro \
	vorbisfile vorbis ogg WildMidi \
	mpg123 samplerate sndfile \
	freetype pixman-1 png z \
	lcf expat icui18n icuuc icudata \
	cpufeatures
LOCAL_LDLIBS := -llog -latomic

# Magic for building dependencies and Player
EXTRA_FLAGS$(TARGET_ARCH_ABI) := \
	--sysroot=$(SYSROOT_INC) \
	-isystem $(NDK_ROOT)/sources/cxx-stl/llvm-libc++/include \
	-isystem $(NDK_ROOT)/sources/android/support/include \
	-isystem $(NDK_ROOT)/sources/cxx-stl/llvm-libc++abi/include \
	-isystem $(SYSROOT_INC)/usr/include \
	-isystem $(SYSROOT_INC)/usr/include/$(TOOLCHAIN_NAME) \
	-isystem $(NDK_ROOT)/sources/android/cpufeatures \
	-B$(SYSROOT_LINK)/usr/lib \
	-L$(SYSROOT_LINK)/usr/lib \
	-Wl,--unresolved-symbols=ignore-all

ifeq ($(COMPILER_CORE_COUNT),)
	COMPILER_CORE_COUNT=4
endif

LLVM_TOOLCHAIN_PREBUILT_ROOT$(TARGET_ARCH_ABI) := $(LLVM_TOOLCHAIN_PREBUILT_ROOT)
LLVM_TOOLCHAIN_PREFIX$(TARGET_ARCH_ABI) := $(LLVM_TOOLCHAIN_PREFIX)
TOOLCHAIN_NAME$(TARGET_ARCH_ABI) := $(TOOLCHAIN_NAME)
BINUTILS_ROOT$(TARGET_ARCH_ABI) := $(BINUTILS_ROOT)
TOOLCHAIN_ROOT$(TARGET_ARCH_ABI) := $(TOOLCHAIN_ROOT)
TOOLCHAIN_PREFIX$(TARGET_ARCH_ABI) := $(TOOLCHAIN_PREFIX)
TARGET_CC$(TARGET_ARCH_ABI) := $(TARGET_CC)
TARGET_CXX$(TARGET_ARCH_ABI) := $(TARGET_CXX)
LLVM_TRIPLE$(TARGET_ARCH_ABI) := $(LLVM_TRIPLE)
TARGET_CFLAGS$(TARGET_ARCH_ABI) := $(TARGET_CFLAGS)
TARGET_CXXFLAGS$(TARGET_ARCH_ABI) := $(TARGET_CXXFLAGS)
TARGET_LDFLAGS$(TARGET_ARCH_ABI) := $(TARGET_LDFLAGS)
SYSROOT_LINK$(TARGET_ARCH_ABI) := $(SYSROOT_LINK)
SYSROOT_INC$(TARGET_ARCH_ABI) := $(SYSROOT_INC)
TARGET_PLATFORM_LEVEL$(TARGET_PLATFORM_LEVEL) := $(TARGET_PLATFORM_LEVEL)

native_icu.built:
	./build_native_icu.sh
	touch $@

$(LOCAL_PATH)/src/build_deps_$(TARGET_ARCH_ABI).cpp: $(TARGET_ARCH_ABI)
	touch $@

$(TARGET_ARCH_ABI): native_icu.built
	$(info NDK_ROOT $(NDK_ROOT$@))
	$(info LLVM_TOOLCHAIN_PREBUILT_ROOT $(LLVM_TOOLCHAIN_PREBUILT_ROOT$@))
	$(info LLVM_TOOLCHAIN_PREFIX $(LLVM_TOOLCHAIN_PREFIX$@))
	$(info TOOLCHAIN_NAME $(TOOLCHAIN_NAME$@))
	$(info BINUTILS_ROOT $(BINUTILS_ROOT$@))
	$(info TOOLCHAIN_ROOT $(TOOLCHAIN_ROOT$@))
	$(info TOOLCHAIN_PREFIX $(TOOLCHAIN_PREFIX$@))
	$(info TARGET_CC $(TARGET_CC$@))
	$(info TARGET_CXX $(TARGET_CXX$@))
	$(info LLVM_TRIPLE $(LLVM_TRIPLE$@))
	$(info TARGET_CFLAGS $(TARGET_CFLAGS$@))
	$(info TARGET_CXXFLAGS $(TARGET_CXXFLAGS$@))
	$(info TARGET_LDFLAGS $(TARGET_LDFLAGS$@))
	$(info SYSROOT_LINK $(SYSROOT_LINK$@))
	$(info SYSROOT_INC $(SYSROOT_INC$@))
	$(info TARGET_PLATFORM_LEVEL $(TARGET_PLATFORM_LEVEL$@))

	# Usage of CFLAGS for CXXFLAGS on purpose, otherwise -fno-rtti breaks ICU
	# ac_cv_func_mmap_fixed_mapped=yes fixes mpg123 build
	# ac_cv_func_getisax=0 fixes x86 pixman build
	rm -rf $(DEPS_DIR$@)
	cp -r $(CORE_DIR)/builds/libretro/deps $(DEPS_DIR$@)
	sed -i 's/install_lib_icu_native/#install_lib_icu_native/' $(DEPS_DIR$@)/libretro/2_build_cross_toolchain.sh
	sed -i 's/rm -rf icu/#/' $(DEPS_DIR$@)/libretro/2_build_cross_toolchain.sh
	sed -i 's/cp -r icu/#/' $(DEPS_DIR$@)/libretro/2_build_cross_toolchain.sh
	cd $(DEPS_DIR$@)/libretro; \
	RETRO_CC="$(TARGET_CC$@)" RETRO_CXX="$(TARGET_CXX$@)" \
	RETRO_CFLAGS="$(TARGET_CFLAGS$@) $(EXTRA_FLAGS$@)" \
	RETRO_CXXFLAGS="$(TARGET_CFLAGS$@) $(EXTRA_FLAGS$@)" \
	RETRO_LDFLAGS="$(TARGET_LDFLAGS$@)" \
	RETRO_TARGET_HOST="$(TOOLCHAIN_NAME$@)" \
	ICU_VERSION="$(ICU_VERSION)" \
	ICU_CROSS_BUILD="$(CORE_DIR$@)/builds/libretro/deps/libretro/icu-native" \
	ac_cv_func_mmap_fixed_mapped=yes \
	ac_cv_func_getisax=0 \
	./2_build_cross_toolchain.sh

	cd $(DEPS_DIR$@)/libretro/lib; \
	CC="$(TARGET_CC$@)" CXX="$(TARGET_CXX$@)" CFLAGS="$(TARGET_CFLAGS$@) $(EXTRA_FLAGS$@)" \
	CXXFLAGS="$(TARGET_CXXFLAGS$@) $(EXTRA_FLAGS$@)" LDFLAGS="$(TARGET_LDFLAGS$@)" \
	cmake $(CORE_DIR) -DCMAKE_SYSTEM_TYPE=Generic -DPLAYER_TARGET_PLATFORM=libretro \
		-DBUILD_SHARED_LIBS=OFF -DCMAKE_FIND_ROOT_PATH=$(DEPS_DIR$@)/libretro \
		-DPLAYER_ENABLE_TESTS=OFF -DPLAYER_WITH_XMP=OFF \
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY
	cd $(DEPS_DIR$@)/libretro/lib; \
	cmake --build . -- -j$(COMPILER_CORE_COUNT)

include $(BUILD_SHARED_LIBRARY)

$(call import-module,android/cpufeatures)
