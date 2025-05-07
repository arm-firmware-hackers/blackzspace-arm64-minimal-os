#!/bin/bash
set -e

BUSYBOX_VERSION=1.36.1
ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-
ROOTFS_DIR=$(pwd)/busybox-rootfs

echo "[+] Starte Build-Prozess für BusyBox-RootFS für Raspberry Pi 5 (ARM64)"

# Clean previous builds
rm -rf busybox-$BUSYBOX_VERSION $ROOTFS_DIR initramfs.cpio.gz

# Download BusyBox
echo "[+] Lade BusyBox v$BUSYBOX_VERSION herunter..."
wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
cd busybox-$BUSYBOX_VERSION

# Konfiguration
echo "[+] Konfiguriere BusyBox für statischen ARM64-Build..."
make distclean
make defconfig
sed -i 's/.*CONFIG_STATIC.*/CONFIG_STATIC=y/' .config

# Build
echo "[+] Baue BusyBox..."
make CROSS_COMPILE=$CROSS_COMPILE -j$(nproc)
make CROSS_COMPILE=$CROSS_COMPILE install CONFIG_PREFIX=$ROOTFS_DIR

cd ..

# Erstelle minimale Verzeichnisstruktur
echo "[+] Erstelle minimale RootFS-Struktur..."
mkdir -p $ROOTFS_DIR/{proc,sys,dev,etc,tmp}
chmod 755 $ROOTFS_DIR
chmod 1777 $ROOTFS_DIR/tmp

# Init-Skript
echo "[+] Erstelle /init..."
cat > $ROOTFS_DIR/init << 'EOF'
#!/bin/sh
echo "[init] Starte Minimal-BusyBox RootFS"
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
exec /bin/sh
EOF

chmod +x $ROOTFS_DIR/init

# Symlink /init zu busybox (optional)
# ln -sf /bin/busybox $ROOTFS_DIR/init

# Erstelle initramfs
echo "[+] Erstelle initramfs.cpio.gz..."
cd $ROOTFS_DIR
find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz
cd ..

echo "[✔] Fertig. Das initramfs ist in: initramfs.cpio.gz"
