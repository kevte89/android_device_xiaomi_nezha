# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
$(call inherit-product, device/xiaomi/nezha/device.mk)

PRODUCT_DEVICE := nezha
PRODUCT_NAME := lineage_nezha
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := 2512BPNDAC
PRODUCT_MANUFACTURER := Xiaomi
BUILD_FINGERPRINT := Xiaomi/nezha/nezha:16/BQ2A.250705.001-BP2A.250605.031.A3/OS3.0.309.0.WPACNXM:user/release-keys
