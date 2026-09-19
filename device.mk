# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

# Initial integration skeleton; see BRINGUP.md before attempting a ROM build.
$(call inherit-product, device/xiaomi/sm8850-common/common.mk)
$(call inherit-product, vendor/xiaomi/nezha/nezha-vendor.mk)

PRODUCT_SOONG_NAMESPACES += device/xiaomi/nezha

# Device hardware overlays must be derived from the stock overlays before use.
# Do not silently activate reference display/brightness/biometric resources.
PRODUCT_PACKAGES := $(filter-out FrameworkResOverlayXiaomi SettingsOverlayXiaomi SystemUIOverlayXiaomi,$(PRODUCT_PACKAGES))

# Verified Nezha stock haptic packaging; consumed by hardware/xiaomi/vibrator/effect.
PRODUCT_COPY_FILES += \
    vendor/xiaomi/nezha/proprietary/odm/firmware/0_click_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/effect_0.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/0_click_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_0.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/1_doubelClick_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/effect_1.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/1_doubelClick_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_1.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/2_tick_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/effect_2.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/2_tick_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_2.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/3_thud_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/effect_3.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/3_thud_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_3.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/4_pop_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/effect_4.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/4_pop_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_4.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/5_heavyClick_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/effect_5.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/5_heavyClick_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_5.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/6_ringTone1_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_6.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/7_ringTone2_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_7.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/8_ringTone3_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_8.bin \
    vendor/xiaomi/nezha/proprietary/odm/firmware/9_ringTone4_P_RTP.bin:$(TARGET_COPY_OUT_VENDOR)/etc/vibrator/primitive_effect_9.bin
