#!/bin/bash

#https://github.com/luk00casati/smalldebinstaller.git

lsblk

echo "scegliere il disco su cui installare il sistema"

read disco

echo start

echo "vuoi creare da solo partizzioni:[y/n]"
read domanda
if [ "$domanda" = "n" ]
then
# Open fdisk and specify the disk to partition
  fdisk /dev/"$disco" << EOF

  # Create a new primary partition that is 250M in size
  n
  p
  1

  +250M

  # Set the bootable flag for the first partition
  t
  1
  b

  # Create a new primary partition that extends to the end of the disk
  n
  p
  2


  w
  EOF

  mkfs.vfat /dev/"$disco"1
  mkfs.ext4 /dev/"$disco"2
if [ "$domanda" = "y" ]
then
  cfdisk
else
  echo errore
fi
mount /dev/"$disco"2 /mnt #disco sistema
mkdir -p /mnt/boot/efi #efi
mount /dev/"$disco"1 /mnt/boot/efi
apt install debootstrap
debootstrap testing /mnt
cp $PWD/smalldebinstaller/sources.list /mnt/etc/apt
cp $PWD /mnt
for dir in sys dev proc; do mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir ; done
cp /etc/resolv.conf /mnt/etc/
chroot /mnt /bin/bash <<END
apt update
apt -y install locales
dpkg-reconfigure locales
apt -y install linux-image-amd64 sudo ntp network-manager vim
apt -y install git
git clone https://github.com/luk00casati/smalldebinstaller.git
cp smalldebinstaller/fstab /etc/fstab
cp smalldebinstaller/hostname /etc/hostname
cp smalldebinstaller/hosts /etc/hosts
rm -r smalldebinstaller/
dpkg-reconfigure tzdata
apt -y install grub-efi-amd64
grub-install /dev/"$disco"
update-grub
systemctl enable networking
passwd
echo "done may you want make a change before restart es. add user, add software change configurations"
END
chroot /mnt /bin/bash
fi
