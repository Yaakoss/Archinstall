#!/bin/bash

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
exit
