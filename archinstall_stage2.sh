#!/bin/bash

TIMEZONE=Europe/Berlin
LOCALE=de_DE.UTF-8
KEYMAP=de-latin1
HOSTNAME=archie
ROOT_PW=Pomidory
USERNAME=patricia
USERNAME_PW=Pomidory

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
echo yoga >> /etc/hostname
echo $HOSTNAME >> /etc/hostname

echo "Enabling NetworkManager"
systemctl enable NetworkManager.service;

echo "Enabling SSHD"
systemctl enable sshd

echo "Setting Root password"
echo -n $ROOT_PW | passwd -s

echo "Adding user $USERNAME"
useradd -m -G wheel --shell /bin/bash $USERNAME
echo -n $USERNAM̀E_PW |passwd patricia -s
sed -i 's/# %wheel/%wheel/g' /etc/sudoers


