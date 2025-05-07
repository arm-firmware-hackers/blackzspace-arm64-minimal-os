#!/bin/bash





set_permissions() {
    # Set permissions for the boot filesystem
    # This is a placeholder function. You can add your own logic here.
    eco info "Setting permissions for the boot filesystem..."
    

    eco info "Setting permissions for $ROOTFS_DIR..."
    sudo chmod +x -R $ROOTFS_DIR
    chmod +x $ROOTFS_DIR/init
    chmod +x $ROOTFS_DIR/etc/init.d/rcS

    # Example: Set read/write permissions for all users
    chmod -R 777 $BOOTFS_DIR
    
    echo "Permissions set successfully."
}



