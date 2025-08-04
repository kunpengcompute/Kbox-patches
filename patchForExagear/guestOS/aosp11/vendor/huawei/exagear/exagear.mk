WITH_EXAGEAR ?= true
ifeq ($(WITH_EXAGEAR),true)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    exagear.use_pretrans=true

EXAGEAR_PRETRANS_ON_INSTALL ?= true
ifeq ($(EXAGEAR_PRETRANS_ON_INSTALL),true)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    exagear.pretrans_on_install=true
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    exagear.pretrans_on_install=false
endif

ifeq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    exagear.debug=off \
    exagear.pretrans.debug=off
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    exagear.debug=info \
    exagear.log_dir="/data/exagear/log" \
    exagear.pretrans.debug=info \
    exagear.pretrans.log_dir="/data/exagear/pretrans_log"
PRODUCT_COPY_FILES += \
    vendor/huawei/exagear/init/exagear-debug.rc:system/etc/init/exagear-debug.rc:huawei
endif

PRODUCT_COPY_FILES += \
    vendor/huawei/exagear/init/exagear-binfmt.rc:system/etc/init/exagear-binfmt.rc:huawei

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/etc/init/exagear-binfmt.rc \
    system/etc/init/exagear-debug.rc \
    system/bin/preubt_a32a64 \
    system/bin/ubt_a32a64

PRODUCT_PACKAGES += \
    ubt_a32a64 \
    preubt_a32a64

# Use 64-bit system servers
TARGET_ENABLE_MEDIADRM_64 := true

# Use 64-bit dex2oat for better dexopt time.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.dex2oat64.enabled=true

# Build-time pre-translation definitions
EXAGEAR_PRETRANSLATOR := vendor/huawei/exagear/prebuilts/preubt_a32a64_x64
define exagear-pretranslate
$(hide) $(EXAGEAR_PRETRANSLATOR) -j 2 --input-file-name=$(1) --output-file-name=$(2)
endef
define exagear-pretranslate-apk
$(hide) $(EXAGEAR_PRETRANSLATOR) -j 2 --apk --input-file-name=$(1) --output-file-name=$(2)
endef
define exagear-pretranslate-sym
$(hide) $(EXAGEAR_PRETRANSLATOR) -j 2 --input-file-name=$(1) --extra-symbols=$(2) --output-file-name=$(3)
endef

# Fine-grained control over build-time pre-translation
EXAGEAR_PRETRANSLATE ?= true
ifeq ($(EXAGEAR_PRETRANSLATE),true)

EXAGEAR_PRETRANSLATE_ODEX ?= true
EXAGEAR_PRETRANSLATE_BOOT_OAT ?= true
EXAGEAR_PRETRANSLATE_BINARY ?= true
EXAGEAR_PRETRANSLATE_APK ?= true

ifeq ($(EXAGEAR_PRETRANSLATE_ODEX),true)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    exagear.pretrans.odex=true
endif
ifeq ($(EXAGEAR_PRETRANSLATE_BOOT_OAT),true)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    exagear.pretrans.boot_oat=true
endif
ifeq ($(EXAGEAR_PRETRANSLATE_BINARY),true)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    exagear.pretrans.lib=true
endif
ifeq ($(EXAGEAR_PRETRANSLATE_APK),true)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    exagear.pretrans.apk=true
endif
endif

endif # WITH_EXAGEAR
