#!/bin/bash
mkfs -t ext4 ${device}
mkdir ${mountpoint}
cat >> /etc/fstab << EOF
UUID=$(lsblk -no UUID ${device}) ${mountpoint} ext4 defaults,nofail 0 2
EOF
mount -a