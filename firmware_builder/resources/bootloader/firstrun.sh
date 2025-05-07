#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_hostname blackzberry
else
   echo blackzberry >/etc/hostname
   sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\tblackzberry/g" /etc/hosts
fi
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom enable_ssh
else
   systemctl enable ssh
fi
if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'zerobyte' '$5$rKlJcmxWou$PvYD5jypUSwQA/.302O8LY6V0twUQDtUU0wxbIwvXn4'
else
   echo "$FIRSTUSER:"'$5$rKlJcmxWou$PvYD5jypUSwQA/.302O8LY6V0twUQDtUU0wxbIwvXn4' | chpasswd -e
   if [ "$FIRSTUSER" != "zerobyte" ]; then
      usermod -l "zerobyte" "$FIRSTUSER"
      usermod -m -d "/home/zerobyte" "zerobyte"
      groupmod -n "zerobyte" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=zerobyte/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/zerobyte/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /zerobyte /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_wlan 'Vodafone-E271' 'c27d3abfef2ef0e9fab9e4b8db493144aaf1afe0800c3e4d9697957a61741b9e' 'DE'
else
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=DE
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	ssid="Vodafone-E271"
	psk=c27d3abfef2ef0e9fab9e4b8db493144aaf1afe0800c3e4d9697957a61741b9e
}

WPAEOF
   chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
   rfkill unblock wifi
   for filename in /var/lib/systemd/rfkill/*:wlan ; do
       echo 0 > $filename
   done
fi
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_keymap 'de'
   /usr/lib/raspberrypi-sys-mods/imager_custom set_timezone 'Europe/Berlin'
else
   rm -f /etc/localtime
   echo "Europe/Berlin" >/etc/timezone
   dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="de"
XKBVARIANT=""
XKBOPTIONS=""

KBEOF
   dpkg-reconfigure -f noninteractive keyboard-configuration
fi
rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0
