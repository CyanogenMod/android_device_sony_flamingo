# Copyright (C) 2014 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# inherit from msm8226-common
include device/sony/msm8226-common/BoardConfigCommon.mk

# Assert
TARGET_OTA_ASSERT_DEVICE := D2203,flamingo

TARGET_SPECIFIC_HEADER_PATH += device/sony/flamingo/include

# Kernel properties
TARGET_KERNEL_SOURCE := kernel/sony/msm8226
TARGET_KERNEL_CONFIG := cm_arima_8926ss_sp_defconfig
TARGET_DTB_EXTRA_FLAGS := --force-v2

# Hardware Features
BOARD_HARDWARE_CLASS := device/sony/flamingo/cmhw

# Bluetooth
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/sony/flamingo/bluetooth

# Partition information
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1782579200
BOARD_USERDATAIMAGE_PARTITION_SIZE := 1879030784

# Recovery
TARGET_RECOVERY_FSTAB := device/sony/flamingo/rootdir/fstab.qcom
BOARD_USE_CUSTOM_RECOVERY_FONT := \"roboto_10x18.h\"
