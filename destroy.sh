#!/bin/bash
source $HOME/Archinstall/archinstall.conf
umount /mnt --recursive
vgchange -an $VOLUME_GROUP
cryptsetup luksCLose $CRYPT_DEVICE
sgdisk -Z $DISK
rm -rf $HOME/Archinstall
partprobe
