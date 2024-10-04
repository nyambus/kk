#!/bin/bash

bash install_wp.sh
bash permissions_passwords.sh
bash vsftpd.sh
bash sudoers.sh

#Дописать удаление всей истории + всех скриптов для деплоя
bash remove_left.sh
