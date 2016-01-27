# Boot animation
TARGET_SCREEN_HEIGHT := 854
TARGET_SCREEN_WIDTH := 480

$(call inherit-product, device/sony/flamingo/aosp_d2203.mk)

# Inherit CM common Phone stuff.
$(call inherit-product, vendor/cm/config/common_full_phone.mk)

# Enhanced NFC
$(call inherit-product, vendor/cm/config/nfc_enhanced.mk)

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_FINGERPRINT=Sony/D2203/D2203:4.4.2/18.4.C.1.29/4nv_bQ:user/release-keys
PRODUCT_BUILD_PROP_OVERRIDES += PRIVATE_BUILD_DESC="D2203-user 4.4.2 18.4.C.1.29 4nv_bQ release-keys"

PRODUCT_NAME := cm_flamingo
