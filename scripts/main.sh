#!/bin/bash

bash permissions_passwords.sh
bash install_wp.sh
bash vsftpd.sh
bash sudoers.sh

#Дописать удаление всей истории + всех скриптов для деплоя
bash remove_left.sh
