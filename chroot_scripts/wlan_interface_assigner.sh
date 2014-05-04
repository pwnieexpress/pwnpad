#!/system/bin/sh
# Assign internal wlan to wlan0 and external wlan to wlan1
# Author: Grep and Awk
# Modified by: Tim

# Delay script start for Android bootup
sleep 5

# Get device
DEVICE=`cat /data/local/kali/etc/product` &> /dev/null

# Check device
case $DEVICE in

  # Fix for new Pwn Pad and Pwn Phone
  Pwn\ Pad\ 2014|Pwn\ Phone\ 2014)

    # Get MAC address of internal wlan and save as variable
    onboard_wlan_mac=`grep "^Intf0MacAddress=" /data/misc/wifi/WCNSS_qcom_cfg.ini | awk -F"=" '{print$2}' | sed -e 's/\([0-9A-Fa-f]\{2\}\)/\1:/g' -e 's/\(.*\):$/\1/'`

    # Get MAC address of external wlan USB adapter and save as variable
    external_wlan_mac=`busybox ifconfig -a | grep "^wlan" | grep -v "${onboard_wlan_mac}" | awk '{print$5}'`

    # Sleep such that svc commands run properly on boot
    sleep 10

    # Disable Android wifi manager
    svc wifi disable
    sleep 2

    # Set temporary interface name for internal wlan
    busybox nameif temp_onboard "${onboard_wlan_mac}"

    # Set temporary interface name for external wlan
    busybox nameif temp_external "${external_wlan_mac}"

    # Set internal wlan to wlan0
    busybox nameif wlan0 "${onboard_wlan_mac}"

    ifconfig wlan0 up
    # Set external wlan to wlan1
    busybox nameif wlan1 "${external_wlan_mac}"

    # Re-enable Android wifi manager
    svc wifi enable

  # Fix for old Pwn Pad
  Pwn\ Pad\ 2013)

    # Sleep such that svc commands run properly on boot
    sleep 15

    # Enable Android wifi manager to snag onboard mac address
    svc wifi enable
    sleep 5

    # Get MAC address of internal wlan and save as variable
    onboard_wlan_mac=`dmesg |egrep -ri "Broadcom Dongle Host Driver mac=" | awk '{print$10}' |awk -F"mac=" '{print$1$2$3$4$5$6}' | head -n 1`

    # Get MAC address of external wlan USB adapter and save as variable
    external_wlan_mac=`busybox ifconfig -a | grep "^wlan" | grep -iv "${onboard_wlan_mac}" | awk '{print$5}'`

    sleep 1
    # Disable Android wifi manager
    svc wifi disable
    sleep 2

    # Set temporary interface name for internal wlan
    busybox nameif temp_onboard "${onboard_wlan_mac}"

    # Set temporary interface name for external wlan
    busybox nameif temp_external "${external_wlan_mac}"

    # Set internal wlan to wlan0
    busybox nameif wlan0 "${onboard_wlan_mac}"

    # Set external wlan to wlan1
    busybox nameif wlan1 "${external_wlan_mac}"

    # Re-enable Android wifi manager
    svc wifi enable

esac
