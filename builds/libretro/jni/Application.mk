APP_STL := c++_static
APP_ABI := armeabi armeabi-v7a arm64-v8a x86
#APP_ABI := all
APP_PLATFORM := android-14

$(info $(TARGET_ARCH_ABI))
bla:=$(shell ./bootstrap.sh $(TARGET_ARCH_ABI))
