#!/bin/bash
source archinstall.conf
umount /mnt --recursive
vgchange -an $VOLUME_GROUP
cryptsetup luksCLose $CRYPT_DEVICE
sgdisk -Z $DISK
rm -rf $HOME/Archinstall
partprobe
