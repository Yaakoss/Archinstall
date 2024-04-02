#!/bin/bash
source $HOME/Archinstall/archinstall.conf
umount /mnt --recursive
vgchange -an $VOLUME_GROUP
cryptsetup luksClose $CRYPT_DEVICE
sgdisk -Z $DISK
rm -rf $HOME/Archinstall
partprobe
