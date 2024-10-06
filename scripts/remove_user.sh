#!/bin/bash

# Проверяем, что пользователь запустил скрипт с правами администратора
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт должен быть запущен с правами администратора." 
   exit 1
fi

# Проверяем, введено ли имя пользователя
if [ -z "$1" ]; then
    echo "Использование: $0 <имя_пользователя>"
    exit 1
fi

USER_TO_DELETE=$1

# Проверяем, существует ли пользователь
if id "$USER_TO_DELETE" &>/dev/null; then
    # Удаляем пользователя и все его следы
    userdel -r "$USER_TO_DELETE"
    echo "Пользователь $USER_TO_DELETE и все его данные удалены."
else
    echo "Пользователь $USER_TO_DELETE не найден."
    exit 1
fi

# Удаляем запись из /etc/group (если такая имеется)
if grep -q "^$USER_TO_DELETE:" /etc/group; then
    groupdel "$USER_TO_DELETE"
    echo "Группа $USER_TO_DELETE удалена."
fi

# Удаляем все упоминания пользователя в других файлах, таких как /etc/sudoers, /etc/passwd, /etc/shadow
# (Хотя команда userdel должна это делать автоматически)

echo "Удаление пользователя завершено."

