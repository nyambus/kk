#!/bin/bash

bash /root/kk/scripts/network.sh
bash /root/kk/scripts/permissions_password.sh
bash /root/kk/scripts/install_wp.sh
bash /root/kk/scripts/vsftpd.sh
bash /root/kk/scripts/sudoers.sh
bash /root/kk/scripts/postfix.sh

bash remove_left.sh
