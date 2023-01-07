#!/bin/bash

lsblk

echo "Choose the disk to install the system on:"
read disco

echo "Do you want to create your own partitions? [y/n]"
read domanda
if [ "$domanda" = "n" ]
then
  parted /dev/"$disco" <<< $'mklabel msdos\nmkpart primary 1MiB 250MiB\nmkpart primary 251MiB 100%\nprint\nquit'
  mkfs.vfat /dev/"$disco"1
  mkfs.ext4 /dev/"$disco"2
elif [ "$domanda" = "y" ]
then
  # Open cfdisk to allow the user to create their own partitions
  cfdisk /dev/"$disco"
  mkfs.vfat /dev/"$disco"1
  mkfs.ext4 /dev/"$disco"2
else
  echo "Error: invalid input"
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

