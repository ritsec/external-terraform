#!/bin/bash
mkfs -t ext4 ${device}
mkdir ${mountpoint}
UUID=$(lsblk -no UUID ${device})
cat >> /etc/fstab << EOF
UUID=${UUID} ${mountpoint} ext4 defaults,nofail 0 2
EOF
mount -a