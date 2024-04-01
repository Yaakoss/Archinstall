#!/bin/bash
clear
set -a

echo -ne "
_______________________________________

     Patty's Arch install script

_______________________________________"

source archinstall.conf
loadkeys $Keyboard_Layout
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 20/g' /etc/pacman.conf
sed -i -z 's/#\[multilib\]\n#Include/\[multilib\]\nInclude/' /etc/pacman.conf
reflector --country France,Germany --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sgdisk -Z $DISK
sgdisk $DISK -n 1::+1GiB -t 1:ef00
sgdisk $DISK -n 2::
sgdisk -p $DISK
ROOT_PARTITON=$DISK"2"
cryptsetup -q luksFormat --label Arch $ROOT_PARTITION $Crypt_Password
