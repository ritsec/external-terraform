#!/bin/bash
sed -i 's/#Port 22/Port 65432/g' /etc/ssh/sshd_config
systemctl restart sshd