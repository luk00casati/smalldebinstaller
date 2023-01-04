#!/bin/bash

#https://github.com/luk00casati/smalldebinstaller.git
su

read disco

echo start

mount /dev/"$disco"2 /mnt #disco sistema
mkdir -p /mnt/boot/efi #efi
mount /dev/"$disco"1 /mnt/boot/efi
apt install debootstrap
debootstrap testing /mnt
cp /smalldebinstaller/sources.list /mnt/etc/apt
for dir in sys dev proc; do mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir ; done
cp /etc/resolv.conf /mnt/etc/
chroot /mnt /bin/bash
apt update
apt install locales
dpkg-reconfigure locales
apt install linux-image-amd64 sudo ntp network-manager vim
cp /smalldebinstaller/fstab /etc/fstab
cp /smalldebinstaller/hostname /etc/hostname
cp /smalldebinstaller/hosts /etc/hosts
dpkg-reconfigure tzdata
apt install grub-efi-amd64
grub-install /dev/"$disco"
update-grub
systemctl enable NetworkManager
echo 'done may you want make a change before restart es. add user add software change configurations"
