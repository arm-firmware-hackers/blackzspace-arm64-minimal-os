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

BOOTFS_OUTPUT_DIR=$(pwd)/output/bootfs
ROOTFS_OUTPUT_DIR=$(pwd)/output/rootfs
KERNEL_OUTPUT_DIR=$(pwd)/output/kernel
INITRAMFS_OUTPUT_DIR=$(pwd)/output/initramfs




source $SCRIPT_DIR/globals/colored.sh

source $SCRIPT_DIR/build_rootfs.sh
source $SCRIPT_DIR/build_busybox.sh
source $SCRIPT_DIR/build_files.sh
source $SCRIPT_DIR/build_initramfs.sh

source $SCRIPT_DIR/set_permissions.sh





BUSYBOX_VERSION=1.36.1
ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-


BOOT_IMAGE=boot.vfat
BOOT_IMAGE_SIZE=256M
BOOT_IMAGE_DIR=$BOOTFS_OUTPUT_DIR

ROOT_IMAGE=rootfs.ext4
ROOT_IMAGE_SIZE=2G
ROOT_IMAGE_DIR=$ROOTFS_OUTPUT_DIR

KERNEL_IMAGE=kernel.img
KERNEL_IMAGE_DIR=$KERNEL_OUTPUT_DIR

INIRAMFS_NAME=initramfs.cpio.gz
INIRAMFS_DIR=$INITRAMFS_OUTPUT_DIR




initialise() {
    eco info "ARM-Firmware Builder für Raspberry Pi wurde gestartet !..."

    eco info "[+] Starte Initialisierung..."
    eco info "[+] Erstelle Verzeichnisse: $SCRIPT_DIR, $CONFIGS_DIR, $BUILD_DIR, $OUTPUT_DIR, $KERNEL_DIR, $ROOTFS_DIR, $BOOTFS_DIR, $TOOLCHAIN_DIR, $BOOTFS_OUTPUT_DIR $ROOTFS_OUTPUT_DIR $KERNEL_OUTPUT_DIR $INITRAMFS_OUTPUT_DIR !..."
    mkdir -p $SCRIPT_DIR $CONFIGS_DIR $BUILD_DIR $OUTPUT_DIR $KERNEL_DIR $ROOTFS_DIR $BOOTFS_DIR $TOOLCHAIN_DIR $BOOTFS_OUTPUT_DIR $ROOTFS_OUTPUT_DIR $KERNEL_OUTPUT_DIR $INITRAMFS_OUTPUT_DIR
    
    eco success "[+] Initialisierung abgeschlossen !..."
    echo "[+] Starte Build-Prozess für BusyBox-RootFS (ARM64)"
}





main() {
    initialise;

    build_rootfs;

    busybox;

    build_files;

    build_initramfs;

    set_permissions;
}


main;