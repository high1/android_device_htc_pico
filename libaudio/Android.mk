# Copyright 2011 The Android Open Source Project

#AUDIO_POLICY_TEST := true
#ENABLE_AUDIO_DUMP := true

ifeq ($(TARGET_BOOTLOADER_BOARD_NAME),pico)
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    audio_hw_hal.cpp \
    HardwarePinSwitching.c

TARGET_HAS_QACT := false
ifeq ($(TARGET_HAS_QACT),true)
LOCAL_SRC_FILES += \
    AudioHardware_cad.cpp
else
LOCAL_SRC_FILES += \
    AudioHardware.cpp
endif

ifeq ($(BOARD_HAVE_BLUETOOTH),true)
  LOCAL_CFLAGS += -DWITH_A2DP
endif

ifeq ($(BOARD_HAVE_QCOM_FM),true)
  LOCAL_CFLAGS += -DWITH_QCOM_FM
  LOCAL_CFLAGS += -DQCOM_FM_ENABLED
endif

ifeq ($(call is-android-codename-in-list,ICECREAM_SANDWICH),true)
  LOCAL_CFLAGS += -DREG_KERNEL_UPDATE
endif

ifeq ($(strip $(BOARD_USES_SRS_TRUEMEDIA)),true)
LOCAL_CFLAGS += -DSRS_PROCESSING
$(shell mkdir -p $(OUT)/obj/SHARED_LIBRARIES/libsrsprocessing_intermediates/)
$(shell touch $(OUT)/obj/SHARED_LIBRARIES/libsrsprocessing_intermediates/export_includes)
endif

LOCAL_CFLAGS += -DQCOM_VOIP_ENABLED
ifeq ($(TARGET_QCOM_TUNNEL_LPA_ENABLED),true)
LOCAL_CFLAGS += -DQCOM_TUNNEL_LPA_ENABLED
endif

LOCAL_SHARED_LIBRARIES := \
    libcutils       \
    libutils        \
    libmedia

ifneq ($(TARGET_SIMULATOR),true)
LOCAL_SHARED_LIBRARIES += libdl
endif

ifeq ($(TARGET_HAS_QACT),true)
LOCAL_SHARED_LIBRARIES += libaudcal
    LOCAL_CFLAGS += -DTARGET_HAS_QACT
	# hack for prebuilt
	$(shell mkdir -p $(OUT)/obj/SHARED_LIBRARIES/libaudcal_intermediates/)
	$(shell touch $(OUT)/obj/SHARED_LIBRARIES/libaudcal_intermediates/export_includes)
endif
LOCAL_STATIC_LIBRARIES := \
    libmedia_helper \
    libaudiohw_legacy

LOCAL_MODULE := audio.primary.msm7x27a
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw
LOCAL_MODULE_TAGS := optional

LOCAL_CFLAGS += -fno-short-enums

LOCAL_C_INCLUDES := $(TARGET_OUT_HEADERS)/mm-audio/audio-alsa
ifeq ($(TARGET_HAS_QACT),true)
LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audcal
endif
LOCAL_C_INCLUDES += hardware/libhardware/include
LOCAL_C_INCLUDES += hardware/libhardware_legacy/include
LOCAL_C_INCLUDES += frameworks/base/include
LOCAL_C_INCLUDES += system/core/include

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

include $(BUILD_SHARED_LIBRARY)

# The audio policy is implemented on top of legacy policy code
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    AudioPolicyManager.cpp \
    audio_policy_hal.cpp

LOCAL_SHARED_LIBRARIES := \
    libcutils \
    libutils \
    libmedia

LOCAL_STATIC_LIBRARIES := \
    libaudiohw_legacy \
    libmedia_helper \
    libaudiopolicy_legacy

LOCAL_MODULE := audio_policy.msm7x27a
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw
LOCAL_MODULE_TAGS := optional

ifeq ($(BOARD_HAVE_BLUETOOTH),true)
  LOCAL_CFLAGS += -DWITH_A2DP
endif


LOCAL_C_INCLUDES := hardware/libhardware_legacy/audio

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

include $(BUILD_SHARED_LIBRARY)

endif # TARGET_BOOTLOADER_BOARD_NAME
