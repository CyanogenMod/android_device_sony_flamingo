#!/bin/bash

# Copyright (C) 2010 The Android Open Source Project
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

DEVICE=tianchi
MANUFACTURER=sony

if [[ -z "${ANDROIDFS_DIR}" ]]; then
    ANDROIDFS_DIR=../../../backup-${DEVICE}
fi

echo Pulling files from ${ANDROIDFS_DIR}
DEVICE_BUILD_ID=`cat ${ANDROIDFS_DIR}/system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`

BASE_PROPRIETARY_DEVICE_DIR=vendor/$MANUFACTURER/$DEVICE/proprietary
PROPRIETARY_DEVICE_DIR=../../../vendor/$MANUFACTURER/$DEVICE/proprietary

mkdir -p $PROPRIETARY_DEVICE_DIR

for NAME in bin etc etc/acdbdata etc/acdbdata/MTP etc/acdbdata/QRD etc/firmware lib lib/egl lib/hw lib/sysmon vendor vendor/etc vendor/firmware vendor/firmware/keymaster vendor/lib vendor/lib/drm vendor/lib/egl vendor/lib/hw vendor/lib/mediadrm vendor/lib/rfsa vendor/lib/rfsa/adsp vendor/lib/soundfx
do
    mkdir -p $PROPRIETARY_DEVICE_DIR/$NAME
done

BLOBS_LIST=../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk

(cat << EOF) | sed s/__DEVICE__/$DEVICE/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
# Copyright (C) 2010 The Android Open Source Project
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

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES :=

# All the blobs
PRODUCT_COPY_FILES += \\
EOF

# copy_file
# pull file from the device and adds the file to the list of blobs
#
# $1 = src/dst name
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_DEVICE_DIR
copy_file()
{
    echo Pulling \"$1\"
    if [[ -z "${ANDROIDFS_DIR}" ]]; then
        NAME=$1
        adb pull /$2/$1 $PROPRIETARY_DEVICE_DIR/$3/$2
    else
        NAME=`basename ${ANDROIDFS_DIR}/$2/$1`
        rm -f $PROPRIETARY_DEVICE_DIR/$3/$NAME
        cp ${ANDROIDFS_DIR}/$2/$NAME $PROPRIETARY_DEVICE_DIR/$3/$NAME
    fi

    if [[ -f $PROPRIETARY_DEVICE_DIR/$3/$NAME ]]; then
        echo   $BASE_PROPRIETARY_DEVICE_DIR/$3/$NAME:$2/$NAME \\ >> $BLOBS_LIST
    else
        echo Failed to pull $1. Giving up.
        exit -1
    fi
}

# copy_files
# pulls a list of files from the device and adds the files to the list of blobs
#
# $1 = list of files
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_DEVICE_DIR
copy_files()
{
    for NAME in $1
    do
        copy_file "$NAME" "$2" "$3"
    done
}

# copy_files_glob
# pulls a list of files matching a pattern from the device and
# adds the files to the list of blobs
#
# $1 = pattern/glob
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_DEVICE_DIR
copy_files_glob()
{
    for NAME in "${ANDROIDFS_DIR}/$2/"$1
    do
        copy_file "`basename $NAME`" "$2" "$3"
    done
}

# copy_local_files
# puts files in this directory on the list of blobs to install
#
# $1 = list of files
# $2 = directory path on device
# $3 = local directory path
copy_local_files()
{
    for NAME in $1
    do
        echo Adding \"$NAME\"
        echo device/$MANUFACTURER/$DEVICE/$3/$NAME:$2/$NAME \\ >> $BLOBS_LIST
    done
}

COMMON_BIN="
	adsprpcd
	bridgemgrd
	fm_qsoc_patches
	fmconfig
	hci_qcomm_init
	mm-qcamera-daemon
	netmgrd
	port-bridge
	qmiproxy
	qmuxd
	radish
	rmt_storage
	time_daemon
        "
copy_files "$COMMON_BIN" "system/bin" "bin"

COMMON_BIN_EXTRAS="
	acc_cal_data_manager
	btnvtool
	cal_data_manager
	chargemon
	ds_fmc_appd
	gsiff_daemon
	hvdcp
	irsc_util
	mm-pp-daemon
	mpdecision
	ptt_socket_app
	qcom-system-daemon
	qseecomd
	rfs_access
	sensors.qcom
	"
copy_files "$COMMON_BIN_EXTRAS" "system/bin" "bin"

SONY_BIN="
	credmgrd
	display_color_calib
	illumination_service
	scd
	scdnotifier
	sct_service
	suntrold
	system_monitor
	taimport
	ta_qmi_service
	updatemiscta
	"
copy_files "$SONY_BIN" "system/bin" "bin"

copy_files_glob "MTP_*.acdb" "system/etc/acdbdata/MTP" "etc/acdbdata/MTP"

copy_files_glob "QRD_*.acdb" "system/etc/acdbdata/QRD" "etc/acdbdata/QRD"

copy_files_glob "adsp*" "system/etc/firmware" "etc/firmware"

copy_files_glob "cmnlib*" "system/etc/firmware" "etc/firmware"

copy_files_glob "mba*" "system/etc/firmware" "etc/firmware"

copy_files_glob "modem*" "system/etc/firmware" "etc/firmware"

copy_files_glob "tzhdcp*" "system/etc/firmware" "etc/firmware"

copy_files_glob "tzlibasb*" "system/etc/firmware" "etc/firmware"

copy_files_glob "tzsuntory*" "system/etc/firmware" "etc/firmware"

copy_files_glob "venus*" "system/etc/firmware" "etc/firmware"

copy_files_glob "wcnss*" "system/etc/firmware" "etc/firmware"

COMMON_ETC_FIRMWARE="
	a225_pfp.fw
	a225_pm4.fw
	a225p5_pm4.fw
	a300_pfp.fw
	a300_pm4.fw
	a330_pfp.fw
	a330_pm4.fw
	leia_pfp_470.fw
	leia_pm4_470.fw
	cpp_firmware_v1_1_1.fw
	cpp_firmware_v1_1_6.fw
	cpp_firmware_v1_2_0.fw
	cyttsp4_fw.bin
	"
copy_files "$COMMON_ETC_FIRMWARE" "system/etc/firmware" "etc/firmware"

COMMON_LIB="
	lib_asb_tee.so
	libMiscTaAccessor.so
	libcamera_clientsemc.so
	libcnefeatureconfig.so
	libidd.so
	libkeyctrl.so
	liblights-core.so
	libloc_api_v02.so
	libloc_ds_api.so
	libmiscta.so
	libmmcamera_interface.so
	libmmjpeg_interface.so
	libmorpho_defocus_jni.so
	libmorpho_denoiser.so
	libmorpho_easy_hdr.so
	libmorpho_edit_engine.so
	libmorpho_fdw.so
	libmorpho_hdr_checker.so
	libmorpho_image_stabilizer3.so
	libmorpho_movie_stabilizer3.so
	libmorpho_object_tracker2.so
	libmorpho_posture_detect.so
	libmorpho_scene_detector.so
	libmorpho_super_resolution.so
	libnfc-nci.so
	libpin-cache.so
	libprotobuf-c.so
	libqomx_core.so
	libsys-utils.so
	libsysmon.so
	libsysmon_idd.so
	libsysmon_jni.so
	libta.so
	"
copy_files "$COMMON_LIB" "system/lib" "lib"

COMMON_LIB_EGL="
	egl.cfg
	libGLES_android.so
	"
copy_files "$COMMON_LIB_EGL" "system/lib/egl" "lib/egl"

COMMON_LIB_HW="
	camera.msm8226.so
	lights.default.so
	nfc_nci_pn547.msm8226.so
	"
copy_files "$COMMON_LIB_HW" "system/lib/hw" "lib/hw"

copy_files_glob "sysmon*" "system/lib/sysmon" "lib/sysmon"

COMMON_VENDOR_ETC="
	audio_effects.conf
	"
copy_files "$COMMON_VENDOR_ETC" "system/vendor/etc" "vendor/etc"

COMMON_VENDOR_FIRMWARE="
	libpn547_fw.so
	"
copy_files "$COMMON_VENDOR_FIRMWARE" "system/vendor/firmware" "vendor/firmware"

copy_files_glob "keymaster*" "system/vendor/firmware/keymaster" "vendor/firmware/keymaster"

copy_files_glob "lib*.so" "system/vendor/lib" "vendor/lib"

COMMON_VENDOR_LIB_DRM="
	libdrmwvmplugin.so
	"
copy_files "$COMMON_VENDOR_LIB_DRM" "system/vendor/lib/drm" "vendor/lib/drm"

COMMON_VENDOR_LIB_EGL="
	eglsubAndroid.so
	libEGL_adreno.so
	libGLESv1_CM_adreno.so
	libGLESv2_adreno.so
	libq3dtools_adreno.so
	"
copy_files "$COMMON_VENDOR_LIB_EGL" "system/vendor/lib/egl" "vendor/lib/egl"

COMMON_VENDOR_LIB_HW="
	flp.default.so
	power.qcom.so
	sensors.msm8226.so
	"
copy_files "$COMMON_VENDOR_LIB_HW" "system/vendor/lib/hw" "vendor/lib/hw"

COMMON_VENDOR_LIB_MEDIADRM="
	libwvdrmengine.so
	"
copy_files "$COMMON_VENDOR_LIB_MEDIADRM" "system/vendor/lib/mediadrm" "vendor/lib/mediadrm"

COMMON_VENDOR_LIB_RFSA_ADSP="
	libadsp_denoise_skel.so
	libdspCV_skel.so
	libfastcvadsp.so
	libfastcvadsp_skel.so
	"
copy_files "$COMMON_VENDOR_LIB_RFSA_ADSP" "system/vendor/lib/rfsa/adsp" "vendor/lib/rfsa/adsp"

COMMON_VENDOR_LIB_SOUNDFX="
	libqcbassboost.so
	libqcreverb.so
	libqcvirt.so
	"
copy_files "$COMMON_VENDOR_LIB_SOUNDFX" "system/vendor/lib/soundfx" "vendor/lib/soundfx"

#B2G_TIME_BUNDLE="
#        chrome.manifest
#        timeservice.js
#        "
#copy_files "$B2G_TIME_BUNDLE" "system/b2g/distribution/bundles/b2g_time" ""

echo $BASE_PROPRIETARY_DEVICE_DIR/lib/libcnefeatureconfig.so:obj/lib/libcnefeatureconfig.so \\ >> $BLOBS_LIST
echo $BASE_PROPRIETARY_DEVICE_DIR/vendor/lib/libtime_genoff.so:obj/lib/libtime_genoff.so \\ >> $BLOBS_LIST

