APP_STL := c++_static
APP_ABI := armeabi armeabi-v7a
# x86 arm8-v7a
#APP_ABI := all
APP_PLATFORM := android-14

$(info $(TARGET_ARCH_ABI))
bla:=$(shell ./bootstrap.sh $(TARGET_ARCH_ABI))
