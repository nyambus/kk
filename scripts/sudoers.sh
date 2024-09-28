#!/bin/bash

apt install sudo
echo > /etc/sudoers.d/conf_for_wpterm <<EOF
www-data ALL=(ALL) NOPASSWD: /usr/sbin/nginx
EOF
