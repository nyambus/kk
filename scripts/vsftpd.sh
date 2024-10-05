#!/bin/bash

#Создание папки для 1 шага
mkdir -p /home/IvanPopov_IT/ftp/FilesForMyFirstJob
chmod 555 /home/IvanPopov_IT/ftp
chown IvanPopov_IT:IvanPopov_IT /home/IvanPopov_IT/ftp

#Создание ссылки на users.php
ln -s /var/www/html/wordpress/wp-includes/user.php /home/IvanPopov_IT/ftp/FilesForMyFirstJob/

apt install vsftpd -y
cp /etc/vsftpd.conf{,.bak}

echo 'listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
ssl_enable=NO

#new
chroot_local_user=YES
local_enable=YES
local_root=/home/$USER/ftp' > /etc/vsftpd.conf

#Для входа юзера с nologin
echo "/usr/sbin/nologin" >> /etc/shells
sudo sed -i 's/^auth required pam_shells.so/# &/' /etc/pam.d/vsftpd

systemctl --now enable vsftpd
systemctl restart vsftpd
systemctl status vsftpd
