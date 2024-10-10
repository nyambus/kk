#!/bin/bash 

pip3 install gdown
gdown 'https://drive.google.com/uc?id=1jeL-dsUpZSLBrwEuiculseXvMRuKzZ4i' -O /root/kk/source/wordpress.zip

rm -rf /var/www/html/wordpress/
cp ../source/wordpress.zip /
unzip wordpress.zip
rm -f /wordpress.zip

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

ln /var/www/html/wordpres/wp-includes/user.php /home/IvanPopov/ftp/FilesForMyFirstJob
chmod 777 /var/www/html/wordpres/wp-includes/user.php
