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
