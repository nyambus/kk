#!/bin/bash

#Смена пароля для рута
passwd root << EOF
S>V5>pk@t4*JQV4U
S>V5>pk@t4*JQV4U
EOF

#Пользователь для брутфорса фтп
adduser IvanPopov_IT --allow-bad-names << EOF
12345
12345
EOF

usermod -s /usr/sbin/nologin IvanPopov_IT
