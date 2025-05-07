#!/bin/bash

busybox() {
    eco info "[+] Starte Build-Prozess für BusyBox-RootFS (ARM64)"
    cd $BUILD_DIR
    eco info "[+] Lade BusyBox herunter..."
    wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
    eco info "[+] Entpacke BusyBox..."
    tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
    
    cd busybox-$BUSYBOX_VERSION

    eco info "[+] Konfiguriere BusyBox für statischen ARM64-Build..."
    make defconfig

    eco info "[+] Kopiere Konfiguration..."
    sudo cp -r $CONFIGS_DIR/busybox/.config $BUILD_DIR/busybox-$BUSYBOX_VERSION/.config

    eco info "[+] Baue BusyBox..."
    make CROSS_COMPILE=$CROSS_COMPILE -j$(nproc)
    eco info "[+] Installiere BusyBox in's RootFS !!! ..."
    make CROSS_COMPILE=$CROSS_COMPILE install CONFIG_PREFIX=$ROOTFS_DIR
    eco info "[+] BusyBox installiert in $ROOTFS_DIR"
    eco success "[+] BusyBox-RootFS (ARM64) Build abgeschlossen !..."
}



build_busybox() {
    eco info "[+] Baue BusyBox für Raspberry Pi 5 (ARM64)"

    cd $BUILD_DIR
    export CROSS_COMPILE=aarch64-none-linux-gnu-
    export ARCH=arm64

    eco info "[+] Lade BusyBox herunter..."
    git clone https://git.busybox.net/busybox
    cd busybox

    eco info "[+] Konfiguriere BusyBox für statischen ARM64-Build..."
    make defconfig

    eco info "[+] Kopiere Konfiguration..."
    sudo cp -r $CONFIGS_DIR/busybox/.config $BUILD_DIR/busybox/.config
   
    make -j$(nproc)
    make CONFIG_PREFIX=$ROOTFS_DIR install
    
    eco info "[+] BusyBox installiert in: $ROOTFS_DIR"
    eco success "[+] BusyBox-RootFS (ARM64) Build abgeschlossen !..."
}
