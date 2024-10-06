#!/bin/bash

# Генерируем файл /etc/network/interfaces
echo '# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).
source /etc/network/interfaces.d/*
# The loopback network interface

auto lo
iface lo inet loopback
auto enp1s0
iface enp1s0 inet static
        address 192.168.122.205/24
        gateway 192.168.122.1' > /etc/network/interfaces

# Создаем файл /etc/resolv.conf
echo 'nameserver 192.168.122.1
nameserver 8.8.8.8' > /etc/resolv.conf

systemctl restart networking
