# Disk layout documentation — informational only, no disko (partitions already exist).
#
# Device   Size     Mount          Notes
# -------  -------  ------         -----
# sda      476.9G   (unmounted)    Secondary storage drive
# sdb      953.9G   —              Primary NVMe
#   sdb1     1G     /boot          EFI system partition (vfat)
#   sdb2     4G     [SWAP]         Swap partition
#   sdb3   948.9G   /              Root + /nix/store (ext4)
#
# To mount the secondary drive:
#   sudo mkdir -p /mnt/data
#   sudo mount /dev/sda /mnt/data
#
# This file is imported by hosts/horus/default.nix for documentation purposes.
# It declares no NixOS options.

{ ... }: { }
