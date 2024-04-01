#!/bin/bash
clear
set -a

echo -ne "
_______________________________________

     Patty's Arch install script

_______________________________________
"

source archinstall.conf
loadkeys $KEYBOARD_LAYOUT
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 20/g' /etc/pacman.conf
sed -i -z 's/#\[multilib\]\n#Include/\[multilib\]\nInclude/' /etc/pacman.conf
echo -ne "
Checking mirrors
"
read -p "Pause..." -s -n1
reflector --country $COUNTRY_LIST --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo -ne "
Partitioning Disks
"
sgdisk -Z $DISK
sgdisk $DISK -n 1::+1GiB -t 1:ef00
sgdisk $DISK -n 2::
sgdisk -p $DISK
export ROOT_PARTITION=$DISK"2"
echo "ROOT PARTITION=$ROOT_PARTITION"

read -p "Pause..." -s -n1
echo -n $Crypt_Password | cryptsetup -q luksFormat --label Arch $ROOT_PARTITION -
echo -n $Crypt_Password | cryptsetup -q luksOpen $ROOT_PARTITION $CRYPT_DEVICE -
pvcreate /dev/mapper/$CRYPT_DEVICE
vgcreate $VOLUME_GROUP /dev/mapper/$VOLUME_GROUP
lvcreate -n swap -L10G $VOLUME_GROUP
lvcreate -n root -l100%FREE $VOLUME_GROUP
mkfs.fat -n Efi -F32 $ROOT_PARTITION"1"
mkfs.btrfs -L Root /dev/mapper/$VOLUME_GROUP
