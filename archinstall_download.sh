#!/bin/bash


# Installing git

echo "Installing git."
pacman -Sy --noconfirm --needed git glibc terminus-font
setfont ter-v18b
echo "Cloning the Arch install scriot"
git clone https://github.com/Yaakoss/Archinstall.git

echo "Executing Arch Install Script"

cd $HOME/Archinstall
exec ./archinstall.sh
