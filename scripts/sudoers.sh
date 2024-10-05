#!/bin/bash

apt install sudo -y
echo 'www-data ALL=(ALL) NOPASSWD: /usr/sbin/nginx' >> /etc/sudoers.d/conf_for_wpterm
