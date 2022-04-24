#!/bin/bash

echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[5m  __     _____    _    ____  _____ _____   ____ ___ _     _     ___ _   _  ____  \e[m";
echo -e "\e[5m  \ \   / /_ _|  / \  / ___|| ____|_   _| | __ )_ _| |   | |   |_ _| \ | |/ ___| \e[m";
echo -e "\e[5m   \ \ / / | |  / _ \ \___ \|  _|   | |   |  _ \| || |   | |    | ||  \| | |  _  \e[m";
echo -e "\e[5m    \ V /  | | / ___ \ ___) | |___  | |   | |_) | || |___| |___ | || |\  | |_| | \e[m";
echo -e "\e[5m     \_/  |___/_/   \_\____/|_____| |_|   |____/___|_____|_____|___|_| \_|\____| \e[m";
echo -e "\e[5m                                                                                 \e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo
sleep 1

# Linux Distribution CentOS or Debian

sleep 1
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -1- Getting Linux Distribution";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

get_linux_distribution ()
{ 
    if [ -f /etc/debian_version ]; then
        DIST="DEBIAN"
        HTTP_DIR="/etc/apache2/"
        HTTP_CONFIG=${HTTP_DIR}"apache2.conf"
        PHP_INI="/etc/php/7.0/cli/php.ini"
        MYSQL_CONFIG="/etc/mysql/mariadb.conf.d/50-server.cnf"
    elif [ -f /etc/redhat-release ]; then
        DIST="CENTOS"
        HTTP_DIR="/etc/httpd/"
        HTTP_CONFIG=${HTTP_DIR}"conf/httpd.conf"
        PHP_INI="/etc/php.ini"
        MYSQL_CONFIG="/etc/my.cnf"
    else
        DIST="OTHER"
        echo 'Installation does not support your distribution'
        exit 1
    fi
}

sleep 1
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -4- Generating Mysql Password";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

genpasswd() 
{
    length=$1
    [ "$length" == "" ] && length=16
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${length} | xargs
}
password=$(genpasswd)

if [ -e "/root/passwordMysql.log" ] && [ ! -z "/root/passwordMysql.log" ]
then
    password=$(awk '{print $1}' /root/passwordMysql.log)
fi

touch /root/passwordMysql.log
echo "$password" > /root/passwordMysql.log

sleep 1
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -5- New Mysql password $password and stored in /root/passwordMysql.log";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo



sleep 1
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -9- Downloading Viaset from Source and Extracting";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

mkdir -p /var/www/html/mbilling
cd /var/www/html/mbilling
wget --no-check-certificate https://github.com/viasetsys/astbill/raw/main/build/viaset-build-onfl.tar.gz
tar -xzf viaset-build-onfl.tar.gz
sed -i 's/M4MqoAlxGkFdE16n/$password' /var/www/html/mbilling/protected/commands/MassiveCallCommand.php
sed -i 's/M4MqoAlxGkFdE16n/$password/g' /var/www/html/mbilling/resources/asterisk/mbilling.php

