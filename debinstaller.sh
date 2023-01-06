#!/bin/bash

#https://github.com/luk00casati/smalldebinstaller.git

lsblk

echo "scegliere il disco su cui installare il sistema"

read disco

echo start

mount /dev/"$disco"2 /mnt #disco sistema
mkdir -p /mnt/boot/efi #efi
mount /dev/"$disco"1 /mnt/boot/efi
apt install debootstrap
debootstrap testing /mnt
cp $PWD/sources.list /mnt/etc/apt
cp $PWD /mnt
for dir in sys dev proc; do mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir ; done
cp /etc/resolv.conf /mnt/etc/
chroot /mnt /bin/bash <<END
apt update
apt -y install locales
dpkg-reconfigure locales
apt -y install linux-image-amd64 firmware-linux sudo ntp network-manager vim git
git clone https://github.com/luk00casati/smalldebinstaller.git
cp smalldebinstaller/fstab /etc/fstab
cp smalldebinstaller/hostname /etc/hostname
cp smalldebinstaller/hosts /etc/hosts
rm -r smalldebianinstaller/
dpkg-reconfigure tzdata
apt -y install grub-efi-amd64
grub-install /dev/"$disco"
update-grub
systemctl enable networking
echo "done may you want make a change before restart es. add user change root password add software change configurations"
END
