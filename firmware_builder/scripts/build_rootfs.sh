#!/bin/bash

build_rootfs() {

    dirs="{bin,sbin,etc,proc,sys,home,root,usr/{bin,sbin,share},dev,tmp,var,run,mnt}"

    eco info "[+] Erstelle RootFS Verzeichnisse:\n $dirs !!!"

    mkdir -p $ROOTFS_DIR/{bin,sbin,etc,proc,sys,home,root,usr/{bin,sbin,share},dev,tmp,var,run,mnt}

    eco success "[+] RootFS Verzeichnisse erstellt !!!"
}