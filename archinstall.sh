#!/bin/bash
clear
set -a

cat << "EOF"


 ____       _   _         _           _             _        _           _        _ _                  _       _
|  _ \ __ _| |_| |_ _   _( )___      / \   _ __ ___| |__    (_)_ __  ___| |_ __ _| | |   ___  ___ _ __(_)_ __ | |_
| |_) / _` | __| __| | | |// __|    / _ \ | '__/ __| '_ \   | | '_ \/ __| __/ _` | | |  / __|/ __| '__| | '_ \| __|
|  __/ (_| | |_| |_| |_| | \__ \   / ___ \| | | (__| | | |  | | | | \__ \ || (_| | | |  \__ \ (__| |  | | |_) | |_
|_|   \__,_|\__|\__|\__, | |___/  /_/   \_\_|  \___|_| |_|  |_|_| |_|___/\__\__,_|_|_|  |___/\___|_|  |_| .__/ \__|
                    |___/                                                                               |_|
EOF
#set -x
source archinstall.conf
printf "\nSetting Keyboard Layout\n"
loadkeys $KEYBOARD_LAYOUT
if [ $USER_MODIFIED = 0 ]; then
	echo "You first need to modify archinstall.conf"
	echo " Exiting Arch install Script..."
	exit 1
fi
printf "\n\nAvailable Disk Drives...\n\n"
lsblk -d
printf "\n\nPlease select which drive to use...\n"
read -p "Enter Full Device Name here e.g. /dev/sda: " DISK
#read -p "Abbruch benötigt" -s -n1
if [[ $DISK == *'nvme'* ]]; then
	ROOT_PARTITION=$DISK"p2"
else 
	ROOT_PARTITION=$DISK"2"
fi
printf "\n\nPatching /etc/pacman.conf to use Color and 20 parallel downloads\n"
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 20/g' /etc/pacman.conf
sed -i -z 's/#\[multilib\]\n#Include/\[multilib\]\nInclude/' /etc/pacman.conf
printf "\nChecking mirrors for speed and creating mirrorlist\n"
#read -p "Pause..." -s -n1
reflector --country "$COUNTRY_LIST" --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
#echo "Failsafe"
#exit 1
printf "\nPartitioning Disks\n"
sgdisk -Z $DISK
sgdisk $DISK -n 1::+1GiB -t 1:ef00
sgdisk $DISK -n 2::
sgdisk -p $DISK

#read -p "Pause..." -s -n1
read -p "Please enter the LUKS Password" -s CRYPT_PASSWORD
printf "\nCreating Luks Volume\n"
echo -n $CRYPT_PASSWORD | cryptsetup -q luksFormat --label Arch $ROOT_PARTITION -
echo -n $CRYPT_PASSWORD | cryptsetup -q luksOpen $ROOT_PARTITION $CRYPT_DEVICE -
printf "\ncreating LVM\n"
pvcreate /dev/mapper/$CRYPT_DEVICE
vgcreate $VOLUME_GROUP /dev/mapper/$CRYPT_DEVICE
lvcreate -n swap -L10G $VOLUME_GROUP
lvcreate -n ArchRoot -l100%FREE $VOLUME_GROUP
printf "\nFormating Volumes\n"
mkfs.fat -n Efi -F32 $DISK"1"
mkfs.btrfs -L Root /dev/$VOLUME_GROUP/ArchRoot
mount -o noatime,compress=zstd /dev/$VOLUME_GROUP/ArchRoot /mnt
for i in ${!SUBVOLUMES[@]} ;do btrfs su cr /mnt/${SUBVOLUMES[i]}; done
umount /mnt
for i in ${!SUBVOLUMES[@]} ;do mount -m -o subvol=${SUBVOLUMES[i]},noatime,compress=zstd /dev/$VOLUME_GROUP/ArchRoot /mnt/${MOUNTPOINTS[i]}; done
mount -m -o noatime $DISK"1" /mnt/boot/efi
pacstrap -K /mnt base base-devel linux linux-firmware openssh git vim sudo networkmanager btrfs-progs cryptsetup lvm2 tldr intel-ucode openssh base-devel tldr refind efitools sbsigntools man-db sbctl 
genfstab -U /mnt >> /mnt/etc/fstab
cp -R /root/Archinstall /mnt/root/Archinstall
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt /root/Archinstall/archinstall_stage2.sh
cp -R /root/Archinstall /mnt/home/patricia/Archinstall
arch-chroot /mnt /usr/bin/runuser -u patricia -- /home/patricia/Archinstall/extended_install.sh
arch-chroot /mnt /home/patricia/Archinstall/create_x11_keyboard_conf.sh
