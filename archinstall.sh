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
mount -o noatime,compress=zstd /dev/$VOLUME_GROUP/ArchRoot /mnt
for i in ${!SUBVOLUMES[@]} ;do btrfs su cr /mnt/${SUBVOLUMES[i]}; done
umount /mnt
for i in ${!SUBVOLUMES[@]} ;do mount -m -o subvol=${SUBVOLUMES[i]},noatime,compress=zstd /dev/$VOLUME_GROUP/ArchRoot /mnt/${MOUNTPOINTS[i]}; done
mount -m -o noatime $DISK"1" /mnt/boot/efi
pacstrap -K /mnt base base-devel linux linux-firmware openssh git vim sudo nano networkmanager btrfs-progs cryptsetup lvm2 tldr intel-ucode openssh base-devel git vim tldr intel-ucode refind efitools sbsigntools man-db sbctl 
genfstab -U /mnt >> /mnt/etc/fstab
cp -R /root/Archinstall /mnt/root/Archinstall
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt /root/Archinstall/archinstall_stage2.sh
cp -R /root/Archinstall /mnt/home/patricia/Archinstall
arch-chroot /mnt /usr/bin/runuser -u patricia -- /home/patricia/Archinstall/extended_install.sh
arch-chroot /mnt /home/patricia/Archinstall/create_x11_keyboard_conf.sh
