LOCAL_PATH := $(call my-dir)

# Some handy paths
EXT_PATH := jni/external
SE_PATH := $(EXT_PATH)/selinux
LIBSELINUX := $(SE_PATH)/libselinux/include
LIBSEPOL := $(SE_PATH)/libsepol/include $(SE_PATH)/libsepol/cil/include
LIBLZMA := $(EXT_PATH)/xz/src/liblzma/api
LIBLZ4 := $(EXT_PATH)/lz4/lib
LIBBZ2 := $(EXT_PATH)/bzip2
LIBFDT := $(EXT_PATH)/dtc/libfdt

########################
# Binaries
########################

# magisk main binary
include $(CLEAR_VARS)
LOCAL_MODULE := magisk
LOCAL_STATIC_LIBRARIES := libsepol
LOCAL_SHARED_LIBRARIES := libsqlite libselinux

LOCAL_C_INCLUDES := \
	jni/include \
	jni/external \
	$(LIBSELINUX) \
	$(LIBSEPOL)

LOCAL_SRC_FILES := \
	daemon/magisk.c \
	daemon/daemon.c \
	daemon/socket_trans.c \
	daemon/log_monitor.c \
	daemon/bootstages.c \
	utils/misc.c \
	utils/vector.c \
	utils/xwrap.c \
	utils/list.c \
	utils/img.c \
	utils/file.c \
	magiskhide/magiskhide.c \
	magiskhide/proc_monitor.c \
	magiskhide/hide_utils.c \
	magiskpolicy/magiskpolicy.c \
	magiskpolicy/rules.c \
	magiskpolicy/sepolicy.c \
	magiskpolicy/api.c \
	resetprop/resetprop.cpp \
	resetprop/system_properties.cpp \
	su/su.c \
	su/activity.c \
	su/db.c \
	su/pts.c \
	su/su_daemon.c \
	su/su_socket.c

LOCAL_CFLAGS := -Wno-implicit-exception-spec-mismatch -DIS_DAEMON
LOCAL_CPPFLAGS := -std=c++11
LOCAL_LDLIBS := -llog
include $(BUILD_EXECUTABLE)

# magiskboot
include $(CLEAR_VARS)
LOCAL_MODULE := magiskboot
LOCAL_STATIC_LIBRARIES := liblzma liblz4 libbz2 libfdt
LOCAL_C_INCLUDES := \
	jni/include \
	$(LIBLZMA) \
	$(LIBLZ4) \
	$(LIBBZ2) \
	$(LIBFDT)

LOCAL_SRC_FILES := \
	magiskboot/main.c \
	magiskboot/bootimg.c \
	magiskboot/hexpatch.c \
	magiskboot/compress.c \
	magiskboot/boot_utils.c \
	magiskboot/cpio.c \
	magiskboot/sha1.c \
	magiskboot/types.c \
	magiskboot/dtb.c \
	utils/xwrap.c \
	utils/vector.c
LOCAL_LDLIBS := -lz
include $(BUILD_EXECUTABLE)

# magiskinit
ifeq ($(TARGET_ARCH_ABI), arm64-v8a)
include $(CLEAR_VARS)
LOCAL_MODULE := magiskinit
LOCAL_STATIC_LIBRARIES := libsepol
LOCAL_C_INCLUDES := jni/include $(LIBSEPOL)
LOCAL_SRC_FILES := \
	magiskinit.c \
	magiskboot/boot_utils.c \
	utils/file.c \
	utils/xwrap.c \
	magiskpolicy/rules.c \
	magiskpolicy/sepolicy.c \
	magiskpolicy/api.c
LOCAL_CFLAGS := -DNO_SELINUX
LOCAL_LDFLAGS := -static
include $(BUILD_EXECUTABLE)
endif

# 32-bit static binaries
ifneq ($(TARGET_ARCH_ABI), x86_64)
ifneq ($(TARGET_ARCH_ABI), arm64-v8a)
# b64xz
include $(CLEAR_VARS)
LOCAL_MODULE := b64xz
LOCAL_STATIC_LIBRARIES := liblzma
LOCAL_C_INCLUDES := $(LIBLZMA)
LOCAL_SRC_FILES := b64xz.c
LOCAL_LDFLAGS := -static
include $(BUILD_EXECUTABLE)
# Busybox
include jni/external/busybox/Android.mk
endif
endif

########################
# Externals
########################
include jni/external/Android.mk
