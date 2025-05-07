#!/bin/bash






CURRENT_DIR=$(pwd)

SCRIPT_DIR=$(pwd)/scripts
CONFIGS_DIR=$(pwd)/configs
BUILD_DIR=$(pwd)/build
OUTPUT_DIR=$(pwd)/output

KERNEL_DIR=$(pwd)/build/kernel
ROOTFS_DIR=$(pwd)/build/rootfs
BOOTFS_DIR=$(pwd)/build/bootfs
TOOLCHAIN_DIR=$(pwd)/build/toolchain



BUSYBOX_VERSION=1.36.1
ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-




initialise() {
    echo "[+] Initialisiere Verzeichnisse..."
    mkdir -p $SCRIPT_DIR $CONFIGS_DIR $BUILD_DIR $OUTPUT_DIR $KERNEL_DIR $ROOTFS_DIR $BOOTFS_DIR $TOOLCHAIN_DIR
    
    echo "[+] Erstelle RootFS Verzeichnisse..."
    mkdir -p $ROOTFS_DIR/{bin,sbin,etc,proc,sys,usr/{bin,sbin},dev,tmp,var,mnt}
   
    sudo cp -r .config $BUILD_DIR

}




busybox() {
    echo "[+] Starte Build-Prozess für BusyBox-RootFS für Raspberry Pi 5 (ARM64)"
    cd $BUILD_DIR
    echo "[+] Lade BusyBox v$BUSYBOX_VERSION herunter..."
    wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
    echo "[+] Entpacke BusyBox v$BUSYBOX_VERSION..."
    tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
    
    cd busybox-$BUSYBOX_VERSION

    echo "[+] Konfiguriere BusyBox für statischen ARM64-Build..."
    make defconfig

    echo "Kopiere Konfiguration..."
    sudo cp -r $BUILD_DIR/.config $BUILD_DIR/busybox-$BUSYBOX_VERSION/.config

    echo "[+] Baue BusyBox..."
    make CROSS_COMPILE=$CROSS_COMPILE -j$(nproc)
    echo "[+] Installiere BusyBox in's RootFS !!! ..."
    make CROSS_COMPILE=$CROSS_COMPILE install CONFIG_PREFIX=$ROOTFS_DIR
    echo "[+] BusyBox installiert in $ROOTFS_DIR"
}


build_busybox() {
    echo "[+] Baue BusyBox für Raspberry Pi 5 (ARM64)"
    
    cd $BUILD_DIR
    export CROSS_COMPILE=aarch64-none-linux-gnu-
    export ARCH=arm64

    echo "[+] Lade BusyBox v$BUSYBOX_VERSION herunter..."
    git clone https://git.busybox.net/busybox
    cd busybox

    echo "[+] Konfiguriere BusyBox für statischen ARM64-Build..."
    make defconfig
    echo "Kopiere Konfiguration..."
    sudo mv $BUILD_DIR/.config $BUILD_DIR/busybox/.config
   
    make -j$(nproc)
    make CONFIG_PREFIX=$ROOTFS_DIR install
    echo "BusyBox installed in $ROOTFS_DIR"

}



create_files() {
echo "Creating all important files in rootfs!... .. ."

echo "Creating: init script !!!... .. ."
cat > $ROOTFS_DIR/init <<EOF
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs devtmpfs /dev

echo "Welcome to minimal BusyBox Linux on Raspberry Pi 5"
exec /bin/sh
EOF

echo "Creating: Device-Nodes !!!... .. ."
sudo mknod -m 600 $ROOTFS_DIR/dev/console c 5 1
sudo mknod -m 666 $ROOTFS_DIR/dev/null c 1 3


cat > $BOOTFS_DIR/cmdline.txt <<EOF
console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rw init=/init
EOF

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


echo "Fertig: Alle Wichtigen Dateien erstellt !!!... .. ."
}




create_initramfs() {
    echo "[+] Erstelle: initramfs.cpio.gz..."
    cd $ROOTFS_DIR
    find . | cpio -o -H newc | gzip > $OUTPUT_DIR/initramfs.cpio.gz
    echo "[+] Initramfs erstellt: $OUTPUT_DIR/initramfs.cpio.gz"
}



main() {
    initialise
    busybox
    create_files
    create_initramfs
}


main;