#!/bin/bash



build_initramfs() {
    eco info "[+] Erstelle: initramfs.cpio.gz..."
    cd $ROOTFS_DIR
    find . | cpio -o -H newc | gzip > $OUTPUT_DIR/initramfs.cpio.gz
    eco success "[+] Initramfs erstellt: $OUTPUT_DIR/initramfs.cpio.gz"
}

