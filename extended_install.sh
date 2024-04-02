#!/bin/bash

su patricia
cd ~
mkdir git
cd git
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si
paru -S xorg-server xorg-xinit qtile qtile-extras cantarell-fonts wezterm keepassxc variety python-dbus-next python-psutil noto-color-emoji-fontconfig pipewire pipewire-pulse blueman bolt mesa thorium-browser pasystray rofi-adi1090x pavucontrol
paru -S pasystray pavucontrol pipewire-pulse arandr inetutils nitrogen fastfetch xdg-user-dirs nextcloud-client xaskpass

