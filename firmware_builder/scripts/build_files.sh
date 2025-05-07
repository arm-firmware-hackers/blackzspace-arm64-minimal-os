#!/bin/bash


build_files() {
eco info "[+] Erstelle alle wichtigen Dateien im RootFS..."



eco info "[+] Erstelle: init script !!!... .. ."
cat > $ROOTFS_DIR/init <<EOF
#!/bin/sh

# Mounten der benötigten Dateisysteme
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs devtmpfs /dev
mount -t tmpfs tmpfs /tmp

# Initialisierung von Systemdiensten
echo "[OK] Systemressourcen gemountet"

# Starten eines einfachen Shell-Interpreters oder beliebiger Prozesse
/bin/sh
EOF



eco info "[+] Erstelle: /etc/inittab !!!... .. ."
cat > $ROOTFS_DIR/etc/inittab <<EOF
# /etc/inittab für BusyBox Init

# Systeminitialisierung
::sysinit:/etc/init.d/rcS

# Terminal für Konsole
tty1::respawn:/bin/sh

# Optional: Weitere Konsolen
#tty2::respawn:/bin/sh
#tty3::respawn:/bin/sh

# Poweroff mit Ctrl+Alt+Del
::ctrlaltdel:/sbin/poweroff

# Wenn alles fehlschlägt
::restart:/sbin/init
EOF


eco info "[+] Erstelle: /etc/init.d/rcS !!!... .. ."
cat > $ROOTFS_DIR/etc/init.d/rcS <<EOF
#!/bin/sh
# /etc/init.d/rcS – Startskript für BusyBox Init

echo "[rcS] Mounting virtual filesystems..."

mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t tmpfs tmpfs /tmp

echo "[rcS] Basic mounts complete."

# Optional: Netzwerk starten (wenn ifconfig o.ä. vorhanden ist)
# ifconfig lo up

echo "[rcS] System ready. Launching shell on tty1."
EOF


eco info "[+] Erstelle: /etc/fstab !!!... .. ."
cat > /etc/fstab <<EOF
proc            /proc       proc    defaults        0 0
sysfs           /sys        sysfs   defaults        0 0
devtmpfs        /dev        devtmpfs defaults       0 0
tmpfs           /tmp        tmpfs   defaults        0 0
EOF



eco info "[+] Erstelle: Device-Nodes !!!... .. ."
sudo mknod -m 600 $ROOTFS_DIR/dev/console c 5 1
sudo mknod -m 666 $ROOTFS_DIR/dev/null c 1 3






eco info "[+] Erstelle: $BOOTFS_DIR 's - Konfigurations Datein ! !!!... .. ."
eco info "[+] Erstelle: $BOOTFS_DIR/cmdline.txt !!!... .. ."
cat > $BOOTFS_DIR/cmdline.txt <<EOF
console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rw init=/init
EOF


eco info "[+] Erstelle: $BOOTFS_DIR/config.txt !!!... .. ."
cat > $BOOTFS_DIR/config.txt <<EOF
### CONFIG.TXT ###
dtparam=i2c_arm=on
dtparam=spi=on

#dtparam=i2s=on

dtparam=audio=on

camera_auto_detect=1

display_auto_detect=1

auto_initramfs=1
# initramfs initramfs.gz followkernel

kernel8.img
# kernel=Image

device_tree=bcm2712-rpi-5-b.dtb

arm_64bit=1

dtoverlay=vc4-kms-v3d
max_framebuffers=2
disable_fw_kms_setup=1

disable_overscan=1

arm_boost=1

[cm4]
otg_mode=1

[cm5]
dtoverlay=dwc2,dr_mode=host

[all]
EOF


eco success "Fertig: Alle Wichtigen Dateien wurden erstellt !!!... .. ."
}
