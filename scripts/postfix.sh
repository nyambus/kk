#!/bin/bash 

pip3 install gdown --break-system-packages
gdown 'https://drive.google.com/uc?id=1jeL-dsUpZSLBrwEuiculseXvMRuKzZ4i' -O /root/kk/source/wordpress.zip

rm -f /home/IvanPopov_IT/ftp/FilesForMyFirstJob/user.php

rm -rf /var/www/html/wordpress/
unzip /root/kk/source/wordpress.zip -d /

MYSQL_ROOT_PASSWORD='SV5pk@t4JQV4U'  # Укажите пароль для root
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
drop database wordpress;
create database wordpress;
use wordpress;
source /root/kk/source/wordpress.sql
EOF

chown -R www-data:www-data /var/www/html/wordpress/
cd /var/www/html/wordpress/
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

ln /var/www/html/wordpress/wp-includes/user.php /home/IvanPopov_IT/ftp/FilesForMyFirstJob/
chmod 777 /var/www/html/wordpress/wp-includes/user.php
