#!/system/bin/sh
# Copyright (c) 2010-2013, The Linux Foundation. All rights reserved.
# Copyright (c) 2013 Sony Mobile Communications AB.
# Copyright (c) 2014 FreeXperia Project.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# This script will load and unload the wifi driver to put the wifi in
# in deep sleep mode so that there won't be voltage leakage.
# Loading/Unloading the driver only incase if the Wifi GUI is not going
# to Turn ON the Wifi. In the Script if the wlan driver status is
# ok(GUI loaded the driver) or loading(GUI is loading the driver) then
# the script won't do anything. Otherwise (GUI is not going to Turn On
# the Wifi) the script will load/unload the driver
# This script will get called after post bootup.

serialno="$1"

if [ -e /sys/bus/platform/drivers/msm_hsic_host ]; then
   if [ ! -L /sys/bus/usb/devices/1-1 ]; then
       echo msm_hsic_host > /sys/bus/platform/drivers/msm_hsic_host/unbind
   fi

   chown -h system.system /sys/bus/platform/drivers/msm_hsic_host/bind
   chown -h system.system /sys/bus/platform/drivers/msm_hsic_host/unbind
   chmod -h 0200 /sys/bus/platform/drivers/msm_hsic_host/bind
   chmod -h 0200 /sys/bus/platform/drivers/msm_hsic_host/unbind
fi

if [ -e /data/misc/wifi/WCNSS_qcom_wlan_cal.bin ]; then
    calparm=`ls /sys/module/wcnsscore/parameters/has_calibrated_data`
    if [ -e $calparm ] && [ ! -e /data/misc/wifi/WCN_FACTORY ]; then
        echo 1 > $calparm
    fi
fi

# There is a device file.  Write to the file
# so that the driver knows userspace is
# available for firmware download requests
echo 1 > /dev/wcnss_wlan

# Plumb down the device serial number
echo $serialno > /sys/devices/fb000000.qcom,wcnss-wlan/serial_number

exit 0
