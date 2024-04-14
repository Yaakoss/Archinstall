#!/bin/bash

 12 cat >> /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
 13 Section "InputClass"
 14         Identifier "system-keyboard"
 15         MatchIsKeyboard "on"
 16         Option "XkbLayout" "de"
 17         Option "XkbModel" "pc105"
 18         Option "XkbVariant" "T3"
 19         Option "XkbOptions" "terminate:ctrl_alt_bksp"
 20 EndSection
 21 EOF
exit
