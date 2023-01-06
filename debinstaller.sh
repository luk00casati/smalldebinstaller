#!/bin/bash

#https://github.com/luk00casati/smalldebinstaller.git
cd

lsblk

echo "scegliere il disco su cui installare il sistema"

read disco

echo start

mount /dev/"$disco"2 /mnt #disco sistema
mkdir -p /mnt/boot/efi #efi
mount /dev/"$disco"1 /mnt/boot/efi
apt install debootstrap
debootstrap testing /mnt
cp smalldebinstaller/sources.list /mnt/etc/apt
for dir in sys dev proc; do mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir ; done
cp /etc/resolv.conf /mnt/etc/
chroot /mnt /bin/bash <<END
apt update
apt install locales
dpkg-reconfigure locales
apt install linux-image-amd64 linux-firmware sudo ntp network-manager vim
cp smalldebinstaller/fstab /etc/fstab
cp smalldebinstaller/hostname /etc/hostname
cp smalldebinstaller/hosts /etc/hosts
dpkg-reconfigure tzdata
apt install grub-efi-amd64
grub-install /dev/"$disco"
update-grub
systemctl enable NetworkManager
echo "done may you want make a change before restart es. add user change root password add software change configurations"
END
