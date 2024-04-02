#!/bin/bash

mkdir -p $HOME/efi-keys
cd $HOME/efi-keys
GUID=`uuidgen --random`
echo -n $GUID >> GUID
read -p "Name für das Zertifikat eingeben:" NAME

openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$NAME PK/" -keyout PK.key \
        -out PK.crt -days 3650 -nodes -sha256
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$NAME KEK/" -keyout KEK.key \
        -out KEK.crt -days 3650 -nodes -sha256
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$NAME DB/" -keyout DB.key \
        -out DB.crt -days 3650 -nodes -sha256
openssl x509 -in PK.crt -out PK.cer -outform DER
openssl x509 -in KEK.crt -out KEK.cer -outform DER
openssl x509 -in DB.crt -out DB.cer -outform DER
cert-to-efi-sig-list -g $GUID PK.crt PK.esl
cert-to-efi-sig-list -g $GUID KEK.crt KEK.esl
cert-to-efi-sig-list -g $GUID DB.crt DB.esl
rm -f noPK.esl
touch noPK.esl
sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k PK.key -c PK.crt PK PK.esl PK.auth
sign-efi-sig-list -t "$(date --date='1 second' +'%Y-%m-%d %H:%M:%S')" \
                  -k PK.key -c PK.crt PK noPK.esl noPK.auth

chmod 0600 *.key
sbctl import-keys --db-cert DB.crt --db-key DB.key --kek-cert KEK.crt --kek-key KEK.key --pk-cert PK.crt --pk-key PK.key
cp GUID /usr/share/secureboot/
sbctl enroll-keys --yes-this-might-brick-my-machine
sbctl sign /boot/efi/EFI/refind/refind_x64.efi
sbctl sign /boot/efi/EFI/refind/drivers_x64/btrfs_x64.efi

