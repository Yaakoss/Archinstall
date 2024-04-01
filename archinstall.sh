#!/bin/bash
clear
set -a

echo -ne "
_______________________________________

     Patty's Arch install script

_______________________________________
"
#set -x
source archinstall.conf
echo "Setting Keyboard Layout"
loadkeys $KEYBOARD_LAYOUT
echo "Patching /etc/pacman.conf"
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 20/g' /etc/pacman.conf
sed -i -z 's/#\[multilib\]\n#Include/\[multilib\]\nInclude/' /etc/pacman.conf
echo -ne "
Checking mirrors for speed and creatiung mirrorlist
"
#read -p "Pause..." -s -n1
reflector --country "$COUNTRY_LIST" --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo -ne "
Partitioning Disks
"
sgdisk -Z $DISK
sgdisk $DISK -n 1::+1GiB -t 1:ef00
sgdisk $DISK -n 2::
sgdisk -p $DISK
export ROOT_PARTITION=$DISK"2"
echo "ROOT PARTITION=$ROOT_PARTITION"

#read -p "Pause..." -s -n1
echo -ne "
creating Luks Volume
"
echo -n $CRYPT_PASSWORD | cryptsetup -q luksFormat --label Arch $ROOT_PARTITION -
echo -n $CRYPT_PASSWORD | cryptsetup -q luksOpen $ROOT_PARTITION $CRYPT_DEVICE -
echo " creating LVM"
pvcreate /dev/mapper/$CRYPT_DEVICE
vgcreate $VOLUME_GROUP /dev/mapper/$CRYPT_DEVICE
lvcreate -n swap -L10G $VOLUME_GROUP
lvcreate -n ArchRoot -l100%FREE $VOLUME_GROUP
echo "formating Volumes"
mkfs.fat -n Efi -F32 $ROOT_PARTITION"1"
mkfs.btrfs -L Root /dev/$VOLUME_GROUP/ArchRoot
