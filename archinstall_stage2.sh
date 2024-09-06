#!/bin/bash

TIMEZONE=Europe/Berlin
LOCALE=de_DE.UTF-8
KEYMAP=de-latin1
HOSTNAME=archie
ROOT_PW=Pomidory
USERNAME=patricia
USERNAME_PW=Pomidory
source $HOME/Archinstall/archinstall.conf

echo "Setting TimeZone"
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime;
hwclock --systohc;
systemctl enable systemd-timesyncd.service;

echo "setting language and locales"
sed -i 's/#$LOCALE/$LOCALE/g' /etc/locale.gen
echo LANG=$LOCALE >> /etc/locale.conf
echo KEYMAP=$KEYMAP >> /etc/vconsole.conf
locale-gen

echo "setting Hostname"
echo $HOSTNAME >> /etc/hostname

echo "Enabling NetworkManager"
systemctl enable NetworkManager.service;

echo "Enabling SSHD"
systemctl enable sshd

echo "Setting Root password"
echo -n $ROOT_PW | passwd -s

echo "Adding user $USERNAME"
useradd -m -G wheel --shell /bin/bash $USERNAME
echo -n $USERNAME_PW |passwd patricia -s
sed -i 's/# %wheel/%wheel/g' /etc/sudoers

echo "vm.swappiness = 10" > /etc/sysctl.d/99-swappiness.conf;
sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
sed -i 's/BINARIES=()/BINARIES=(\/usr\/bin\/btrfs)/g' /etc/mkinitcpio.conf
sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
sed -i 's/base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck/base systemd sd-encrypt keyboard autodetect modconf kms sd-vconsole block lvm2 filesystems resume fsck/g' /etc/mkinitcpio.conf
mkdir -p /boot/efi/EFI/Arch-test;
sed -i 's/default_image/#default_image/g' /etc/mkinitcpio.d/linux.preset
sed -i 's/#default_uki/default_uki/g' /etc/mkinitcpio.d/linux.preset
sed -i 's/fallback_image/#fallback_image/g' /etc/mkinitcpio.d/linux.preset
sed -i 's/#fallback_uki/fallback_uki/g' /etc/mkinitcpio.d/linux.preset
sed -i 's/\/efi\/EFI\/Linux\//\/boot\/efi\/EFI\/Arch-test\//g' /etc/mkinitcpio.d/linux.preset
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 20/g' /etc/pacman.conf
sed -i -z 's/#\[multilib\]\n#Include/\[multilib\]\nInclude/' /etc/pacman.conf
pacman-key --init
pacman-key --populate archlinux
pacman -S --noconfirm refind
refind-install
sed -i 's/timeout 20/timeout 5/g' /boot/efi/EFI/refind/refind.conf
echo "default_selection arch-linux.efi" >> /boot/efi/EFI/refind/refind.conf
mkdir -p /etc/cmdline.d
CRYPTLVM_UUID=`blkid $DISK"2" |cut -d' ' -f2 |cut -d\" -f2`
ROOT_UUID=`blkid /dev/$VOLUME_GROUP/ArchRoot |cut -d' ' -f3 |cut -d\" -f2`
echo "rd.luks.name=$CRYPTLVM_UUID=$CRYPT_DEVICE" >> /etc/cmdline.d/root.conf
echo "rootfstype=btrfs" >> /etc/cmdline.d/root.conf
echo "root=UUID=$ROOT_UUID" >> /etc/cmdline.d/root.conf
echo "rootflags=subvol=@" >> /etc/cmdline.d/root.conf
echo "bgrt_disable quiet loglevel=4" >> /etc/cmdline.d/root.conf
echo -ne "

Creating SB-Keys

"
$HOME/Archinstall/create_sb_keys.sh
cat >> /etc/initcpio/post/uki-sbsign << EOF
#!/usr/bin/env bash

uki="\$3"
[[ -n "\$uki" ]] || exit 0

keypairs=(/var/lib/sbctl/keys/db/db.key /var/lib/sbctl/keys/db/db.pem)

for (( i=0; i<\${#keypairs[@]}; i+=2 )); do
    key="\${keypairs[\$i]}" cert="\${keypairs[(( i + 1 ))]}"
    if ! sbverify --cert "\$cert" "\$uki" &>/dev/null; then
        sbsign --key "\$key" --cert "\$cert" --output "\$uki" "\$uki"
    fi
done
EOF
chmod +x /etc/initcpio/post/uki-sbsign; 
mkinitcpio -P
sed -i 's/purge debug lto)/purge !debug lto)/g' /etc/makepkg.conf

