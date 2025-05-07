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



ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-


initialise() {
    mkdir -p $SCRIPT_DIR $CONFIGS_DIR $BUILD_DIR $OUTPUT_DIR $KERNEL_DIR $ROOTFS_DIR $BOOTFS_DIR $TOOLCHAIN_DIR

    mkdir -p $ROOTFS_DIR/{bin,sbin,etc,proc,sys,usr/{bin,sbin},dev,tmp,var,mnt}
    cd $ROOTFS_DIR

}






build_busybox() {
    export CROSS_COMPILE=aarch64-none-linux-gnu-
    export ARCH=arm64

    git clone https://git.busybox.net/busybox
    cd busybox

    make defconfig
    make menuconfig
    make -j$(nproc)
    make CROSS_COMPILE=$CROSS_COMPILE install

    cd _install
    cp -a * $ROOTFS_DIR

}


create_files() {


    echo "Creating files in rootfs"
    echo "Creating init script"
cat > $ROOTFS_DIR/init <<EOF
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs devtmpfs /dev

echo "Welcome to minimal BusyBox Linux on Raspberry Pi 5"
exec /bin/sh
EOF

}

create_initramfs() {
    cd $ROOTFS_DIR
    find . | cpio -o -H newc | gzip > $OUTPUT_DIR/initramfs.cpio.gz
    cd $CURRENT_DIR
}

main() {
    initialise
    build_busybox
    create_files
    create_initramfs
}


main;