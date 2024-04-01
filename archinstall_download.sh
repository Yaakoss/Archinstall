#!/bin/bash


# Installing git

echo "Installing git."
pacman -Sy --noconfirm --needed git glibc

echo "Cloning the ArchTitus Project"
git clone https://github.com/Yaakoss/Archinstall.git

echo "Executing Arch Install Script"

cd $HOME/Archinstall
exec ./archinstall.sh
