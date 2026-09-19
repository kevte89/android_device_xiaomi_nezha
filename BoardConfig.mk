# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/xiaomi/nezha
NEZHA_KERNEL_PATH := device/xiaomi/nezha-kernel
include device/xiaomi/sm8850-common/BoardConfigCommon.mk

# Stock OS3.0.309.0.WPACNXM, product/build.prop and LP metadata.
TARGET_SCREEN_DENSITY := 480
BOARD_SUPER_PARTITION_SIZE := 15300820992
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 15290335232

# Stock boot AVB property and vendor/build.prop, not the ROM patch level.
BOOT_SECURITY_PATCH := 2026-02-01
VENDOR_SECURITY_PATCH := 2026-02-01

BOARD_PREBUILT_DTBOIMAGE := $(NEZHA_KERNEL_PATH)/dtbo.img
BOARD_PREBUILT_DTBIMAGE_DIR := $(NEZHA_KERNEL_PATH)/dtb
TARGET_NO_KERNEL_OVERRIDE := true
TARGET_KERNEL_SOURCE := $(NEZHA_KERNEL_PATH)/kernel-headers
PRODUCT_COPY_FILES += $(NEZHA_KERNEL_PATH)/kernel:kernel

BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(NEZHA_KERNEL_PATH)/vendor_ramdisk/modules.load))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(NEZHA_KERNEL_PATH)/vendor_ramdisk/modules.load.recovery))
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(NEZHA_KERNEL_PATH)/vendor_dlkm/modules.load))

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(NEZHA_KERNEL_PATH)/vendor_ramdisk/,$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules) \
    $(call find-copy-subdir-files,*,$(NEZHA_KERNEL_PATH)/vendor_dlkm/,$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules) \
    $(call find-copy-subdir-files,*,$(NEZHA_KERNEL_PATH)/system_dlkm/,$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules/6.12.23-android16-5-g75e9b1c7ae7c-abogki463945075-4k) \
    $(call find-copy-subdir-files,*,$(NEZHA_KERNEL_PATH)/system_dlkm_flatten/,$(TARGET_COPY_OUT_SYSTEM_DLKM)/flatten/lib/modules)

# Stock vendor_boot command line/bootconfig; fingerprint follows the ROM.
BOARD_KERNEL_CMDLINE := video=vfb:640x400,bpp=32,memsize=3072000 erofs.reserved_pages=64 swinfo.fingerprint=$(LINEAGE_VERSION)
BOARD_BOOTCONFIG := androidboot.hardware=qcom \
    androidboot.memcg=1 \
    androidboot.usbcontroller=a600000.dwc3 \
    androidboot.load_modules_parallel=true \
    androidboot.hypervisor.protected_vm.supported=true \
    androidboot.hypervisor.version=gunyah \
    androidboot.vendor.qspa=true \
    androidboot.serialconsole=0

BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 23068672
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_PVMFWIMAGE_PARTITION_SIZE := 1048576

TARGET_VENDOR_PROP := $(filter-out $(COMMON_PATH)/configs/properties/vendor.prop,$(TARGET_VENDOR_PROP))
TARGET_VENDOR_PROP += $(DEVICE_PATH)/configs/properties/vendor.prop

TARGET_ODM_PROP := $(filter-out $(COMMON_PATH)/configs/properties/odm.prop,$(TARGET_ODM_PROP))
TARGET_ODM_PROP += $(DEVICE_PATH)/configs/properties/odm.prop

TARGET_PRODUCT_PROP := $(filter-out $(COMMON_PATH)/configs/properties/product.prop,$(TARGET_PRODUCT_PROP))
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/configs/properties/product.prop

TARGET_SYSTEM_PROP := $(filter-out $(COMMON_PATH)/configs/properties/system.prop,$(TARGET_SYSTEM_PROP))
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/configs/properties/system.prop

TARGET_SYSTEM_EXT_PROP := $(filter-out $(COMMON_PATH)/configs/properties/system_ext.prop,$(TARGET_SYSTEM_EXT_PROP))
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/configs/properties/system_ext.prop

include vendor/xiaomi/nezha/BoardConfigVendor.mk

# Product guard matches the verified Nezha-309 flash_all.sh check.
TARGET_BOARD_INFO_FILE := $(DEVICE_PATH)/board-info.txt
