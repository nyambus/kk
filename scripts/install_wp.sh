#!/bin/bash

# Установка Apache2
sudo apt install apache2 -y

# Установка PHP
sudo apt-get install php8.2 php8.2-cli php8.2-common php8.2-imap php8.2-redis php8.2-snmp php8.2-xml php8.2-mysqli php8.2-zip php8.2-mbstring php8.2-curl libapache2-mod-php -y

# Установка MariaDB
sudo apt install mariadb-server -y

# Настройка базы данных
sudo mariadb <<EOF
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'kk'; 
CREATE DATABASE 'wordpress'; 
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost'; 
FLUSH PRIVILEGES; 
EXIT;
EOF

# Установка последней версии WordPress
cd /var/www/html
wget https://wordpress.org/latest.zip
unzip latest.zip
rm latest.zip

# Установка прав на файлы и директории
sudo chown -R www-data:www-data wordpress/
cd wordpress/
sudo find . -type d -exec chmod 755 {} \;
sudo find . -type f -exec chmod 644 {} \;

# Настройка файла wp-config.php
cd /var/www/html/wordpress
mv wp-config-sample.php wp-config.php

# Изменение конфигурации wp-config.php
sudo sed -i "s/database_name_here/wordpress/" wp-config.php
sudo sed -i "s/username_here/wordpress/" wp-config.php
sudo sed -i "s/password_here/kk/" wp-config.php

# Создание конфигурационного файла для Apache
cd /etc/apache2/sites-available/
sudo touch wordpress.conf

# Заполнение wordpress.conf
IP_ADDRESS=$(hostname -I | awk '{print $1}')
sudo bash -c 'cat <<EOL > wordpress.conf
<VirtualHost *:80>
    ServerName $IP_ADDRESS
    DocumentRoot /var/www/html/wordpress
    <Directory /var/www/html/wordpress>
        AllowOverride All
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL'

# Активация модуля перезаписи и конфигурации сайта
sudo a2enmod rewrite
sudo a2ensite wordpress.conf

# Проверка синтаксиса конфигурации Apache
sudo apachectl -t

# Перезагрузка Apache
sudo systemctl reload apache2
