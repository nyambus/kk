#!/bin/bash

apt-get update -y && apt-get upgrade -y

# Установка Apache2
apt install apache2 -y

# Установка PHP
apt-get install php8.2 php8.2-cli php8.2-common php8.2-imap php8.2-redis php8.2-snmp php8.2-xml php8.2-mysqli php8.2-zip php8.2-mbstring php8.2-curl libapache2-mod-php -y

# Установка MariaDB
apt install mariadb-server -y

# Настройка базы данных
MYSQL_ROOT_PASSWORD='kk'  # Укажите пароль для root
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'kk'; 
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
sed -i "s/password_here/kk/" wp-config.php

# Создание конфигурационного файла для Apache
cd /etc/apache2/sites-available/

# Заполнение wordpress.conf
IP_ADDRESS=$(hostname -I | awk '{print $1}')
bash -c "cat <<EOL > wordpress.conf
<VirtualHost *:80>
    ServerName $IP_ADDRESS
    DocumentRoot /var/www/html/wordpress
    <Directory /var/www/html/wordpress>
        AllowOverride All
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL"


# Активация модуля перезаписи и конфигурации сайта
a2enmod rewrite
a2ensite wordpress.conf

# Проверка синтаксиса конфигурации Apache
apachectl -t

# Перезагрузка Apache
systemctl reload apache2
