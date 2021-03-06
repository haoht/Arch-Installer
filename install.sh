#!/bin/bash

## 分区
read -p "Do you want to adjust the partition ? (Input y to use fdisk or Enter to continue:  " TMP
if [ "$TMP" == y ] 
then
  fdisk -l
  read -p "Which disk do you want to partition ? (example: /dev/sdX:  " DISK
  fdisk $DISK
fi
fdisk -l
read -p "Input the root mount point:  " ROOT
read -p "Format it ? (y or Enter  " TMP
if [ "$TMP" == y ] 
then 
  read -p "Input y to use EXT4 or defalut to use BTRFS  " TMP
  if [ "$TMP" == y ]
  then mkfs.ext4 $ROOT
  else mkfs.btrfs $ROOT -f
  fi
  mount $ROOT /mnt
fi

read -p "Do you have the /boot mount point? (y or Enter  " BOOT
if [ "$BOOT" == y ] 
then 
  fdisk -l
  read -p "Input the /boot mount point:  " BOOT
  read -p "Format it ? (y or Enter  " TMP
  if [ "$TMP" == y ] 
  then mkfs.fat -F32 $BOOT
  fi
  mkdir /mnt/boot
  mount $BOOT /mnt/boot
fi

read -p "Do you need the swap partition ? (y or Enter  " SWAP
if [ "$SWAP" == y ] 
then 
  fdisk -l
  read -p "Input the swap mount point:  " SWAP
  read -P "Format it ? (y or Enter  " TMP
  if [ "$TMP" == y ] 
  then mkswap $SWAP
  fi
  swapon $SWAP
fi

## 更改软件源
echo "## China Mirrors
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.163.com/archlinux/\$repo/os/\$arch
Server = http://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
read -p "Edit the pacman.conf ? (y or Enter  " TMP
if [ "$TMP" == y ] 
then
  nano /etc/pacman.conf
fi

## 安装基本系统
TMP=n
while [ "$TMP" == n ] 
do
  pacstrap /mnt base base-devel --force
  rm /mnt/etc/fstab
  genfstab -U -p /mnt >> /mnt/etc/fstab
  cat /mnt/etc/fstab
  read -p "Successfully installed ? (n or Enter  " TMP
done

## 进入已安装的系统
wget https://raw.githubusercontent.com/rhatyang/Arch-Installer/master/config.sh
mv config.sh /mnt/root/config.sh
chmod +x /mnt/root/config.sh
arch-chroot /mnt /root/config.sh
