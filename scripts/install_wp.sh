#!/bin/bash

apt-get update -y && apt-get upgrade -y

# Установка Apache2
apt install apache2 unzip -y

# Установка PHP
apt-get install php8.2 php8.2-cli php8.2-common php8.2-imap php8.2-redis php8.2-snmp php8.2-xml php8.2-mysqli php8.2-zip php8.2-mbstring php8.2-curl libapache2-mod-php -y

# Установка MariaDB
apt install mariadb-server -y

# Настройка базы данных
MYSQL_ROOT_PASSWORD='kk'  # Укажите пароль для root
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'GdE0Mne2D5hD'; 
CREATE DATABASE wordpress; 
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost'; 
FLUSH PRIVILEGES; 
EOF


# Установка последней версии WordPress
cd /var/www/html
wget https://wordpress.org/latest.zip
unzip latest.zip
rm latest.zip

# Установка прав на файлы и директории
chown -R www-data:www-data wordpress/
cd wordpress/
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

# Настройка файла wp-config.php
cd /var/www/html/wordpress
mv wp-config-sample.php wp-config.php

# Изменение конфигурации wp-config.php
sed -i "s/database_name_here/wordpress/" wp-config.php
sed -i "s/username_here/wordpress/" wp-config.php
sed -i "s/password_here/GdE0Mne2D5hD/" wp-config.php

# Создание конфигурационного файла для Apache
cd /etc/apache2/sites-available/

#Создание сертификатов
mkdir /etc/ssl/wordpress/
openssl genrsa -out /etc/ssl/wordpress/wordpress.key 2048
openssl req -new -key ваш_ключ.key -out /etc/ssl/wordpress/wordpress.csr
openssl x509 -req -days 365 -in /etc/ssl/wordpress/wordpress.csr -signkey /etc/ssl/wordpress/wordpress.key -out /etc/ssl/wordpress/wordpress.crt

# Заполнение wordpress.conf
a2enmod rewrite
a2enmod ssl

echo '<VirtualHost *:80>
        ServerName 192.168.122.205
        DocumentRoot /var/www/html/wordpress/
        Errorlog ${APACHE_LOG_DIR}/wordpress.log
        Customlog ${APACHE_LOG_DIR}/wordpress.log combined
        
        RewriteEngine On
        RewriteCond %{SERVER_PORT} !^443$
        RewriteRule .* https://%{SERVER_NAME}%{REQUEST_URI} [R=301,L]
</VirtualHost>
<VirtualHost *:443>
        ServerName 192.168.122.205
        DocumentRoot /var/www/html/wordpress
        SSLEngine on
        SSLCertificateFile /etc/ssl/wordpress/wordpress.crt
        SSLCertificateKeyFile /etc/ssl/wordpress/wordpress.key

        Errorlog ${APACHE_LOG_DIR}/wordpress.log
        Customlog ${APACHE_LOG_DIR}/wordpress.log combined
</VirtualHost>' > /etc/apache2/sites-available/wordpress.conf


# Активация модуля перезаписи и конфигурации сайта
a2ensite wordpress.conf

# Проверка синтаксиса конфигурации Apache
apachectl -t

# Перезагрузка Apache
systemctl reload apache2
