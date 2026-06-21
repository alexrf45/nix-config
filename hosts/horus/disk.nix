# Disk layout documentation — informational only, no disko (partitions already exist).
#
# Device   Size     Mount          Notes
# -------  -------  ------         -----
# sda      476.9G   —              Secondary storage drive
#   sda1   470G     /home/anubis   Research + bulk files (ext4)
# sdb      953.9G   —              Primary NVMe
#   sdb1     1G     /boot          EFI system partition (vfat)
#   sdb2     4G     [SWAP]         Swap partition
#   sdb3   948.9G   /              Root + /nix/store (ext4)
#
# /home/anubis is mounted declaratively in hardware-configuration.nix.
#
# This file is imported by hosts/horus/default.nix for documentation purposes.
# It declares no NixOS options.

{ ... }: { }
