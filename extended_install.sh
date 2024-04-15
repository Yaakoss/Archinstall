#!/bin/bash

cd ~
mkdir git
cd git
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si
paru -S xorg-server xorg-xinit qtile qtile-extras cantarell-fonts wezterm keepassxc variety python-dbus-next python-psutil noto-color-emoji-fontconfig pipewire pipewire-pulse blueman bolt mesa thorium-browser pasystray rofi-adi1090x pavucontrol
paru -S pasystray pavucontrol pipewire-pulse arandr inetutils nitrogen fastfetch xdg-user-dirs nextcloud-client xaskpass
exit
cat >> /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "de"
        Option "XkbModel" "pc105"
        Option "XkbVariant" "T3"
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF
