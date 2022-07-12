
include $(CLEAR_VARS)

LOCAL_PATH := $(CURDIR)/jni/gitsave

LOCAL_MODULE := gitsave_native
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libgitsave_native.so

include $(PREBUILT_SHARED_LIBRARY)
