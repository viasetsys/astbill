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
sleep 2

if [[ -f /var/www/html/mbilling/index.php ]]; then
  echo "this server already has Viaset Billing installed";
  exit;
fi

# Linux Distribution CentOS or Debian

sleep 2
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

get_linux_distribution

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -2- Restarting Mysql, Apache and Asterisk";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

startup_services() 
{
    # Startup Services
    if [ ${DIST} = "DEBIAN" ]; then
        systemctl restart mysql
        systemctl restart apache2
        systemctl restart asterisk
    elif  [ ${DIST} = "CENTOS" ]; then
        systemctl restart mariadb
        systemctl restart httpd
        systemctl restart asterisk    
    fi
}

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -3- Setting Time-Zone";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

set_timezone ()
{ 
  yum -y install ntp
  directory=/usr/share/zoneinfo
  for (( l = 0; l < 5; l++ )); do

    echo "entrar no diretorio $directory"
    cd $directory
    files=("")  

    i=0
    s=65    # decimal ASCII "A" 
    for f in *
    do

      if [[ "$i" = "0" && "$l" = "0" ]]; then
        files[i]="BRASIL Brasilia"
        files[i+1]=""
      else
        files[i]="$f"
          files[i+1]=""
      fi      
        ((i+=2))
        ((s++))
    done

    files[i+1]="MAIN MENU"
    files[i+2]="Back to main menu"

    zone=$(whiptail --title "Restore Files" --menu "Please select your timezone" 20 60 12 "${files[@]}" 3>&1 1>&2 2>&3)


    if [ "$zone" = "BRASIL Brasilia" ]; then
      echo "é um arquivo, setar timezone BRASIL"
      directory=$directory/America/Sao_Paulo  
      break
    fi

    directory=$directory/$zone


    if [ -f "$directory" ]; then
      #echo "é um arquivo, setar timezone"
      break
    fi

    if [ "$zone" = "MAIN MENU" ]; then
      directory=/usr/share/zoneinfo
      l=0
    fi

    if test -z "$zone"; then
      break
    fi  

    echo fim do loop

  done

  if [ -f "$directory" ]; then    
    rm -f /etc/localtime
    ln -s $directory /etc/localtime
    phptimezone="${directory//\/usr\/share\/zoneinfo\//}"
    phptimezone="${phptimezone////\/}"
    sed -i '/date.timezone/s/= .*/= '$phptimezone'/' /etc/php.ini
    systemctl reload httpd
  fi

}

set_timezone

sleep 2
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

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -5- New Mysql and stored in /root/passwordMysql.log";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -6- Disabling Selinux, Setting Mariadb Repo";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

if  [ ${DIST} = "CENTOS" ]; then
    sed 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config > borra && mv -f borra /etc/selinux/config
fi

if [ ${DIST} = "CENTOS" ]; then
echo '[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2.43/centos7-amd64/
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1' > /etc/yum.repos.d/MariaDB.repo 
fi

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -7- Installing Viaset Billing Dependencies";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

if [ ${DIST} = "DEBIAN" ]; then
    apt-get update --allow-releaseinfo-change
    export LC_ALL="en_US.UTF-8"
    apt-get -o Acquire::Check-Valid-Until=false update 
    apt-get install -y autoconf automake devscripts gawk ntpdate ntp g++ git-core curl sudo xmlstarlet unixodbc-bin apache2 libjansson-dev git  odbcinst1debian2 libodbc1 odbcinst unixodbc unixodbc-dev
    apt-get install -y php-fpm php  php-dev php-common php-cli php-gd php-pear php-cli php-sqlite3 php-curl php-mbstring unzip libapache2-mod-php uuid-dev libxml2 libxml2-dev openssl libcurl4-openssl-dev gettext gcc g++ libncurses5-dev sqlite3 libsqlite3-dev subversion mpg123
    apt-get -y install mariadb-server php-mysql
    apt-get install -y  unzip git libcurl4-openssl-dev htop
elif  [ ${DIST} = "CENTOS" ]; then
    yum clean all
	#rm -rf /var/cache/yum/*
    yum -y install mysql mariadb-server mariadb-devel mariadb php-mysql mysql-connector-odbc   
fi


sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -9- Downloading Viaset from Source and Extracting";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

cd /var/www/html/
wget --no-check-certificate https://github.com/viasetsys/astbill/raw/main/build/viaset-build.tar.gz
tar -xzf viaset-build.tar.gz

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -13- Changed tmp folder Permission to 777";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

chmod -R 777 /tmp

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo "---- Your New Mysql root password is $password ----";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -18- Enabling and Restarting HTTPD, Mariadb and NTP";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

if [ ${DIST} = "DEBIAN" ]; then
    systemctl start mariadb
    systemctl enable apache2 
    systemctl enable mariadb
    chkconfig ntp on
else [ -f /etc/redhat-release ]
    systemctl enable httpd
    systemctl enable mariadb
    systemctl start mariadb
    systemctl enable ntpd
fi

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -19- Setting Mysql root password";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

  mysql -uroot -e "UPDATE mysql.user SET password=PASSWORD('${password}') WHERE user='root'; FLUSH PRIVILEGES;"
  
sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -20- Updating Mysql Config in my.cnf";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

if [ ${DIST} = "CENTOS" ]; then
echo "
[mysqld]
join_buffer_size = 128M
sort_buffer_size = 2M
read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
secure-file-priv = ''
symbolic-links=0
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
max_connections = 500
[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
" > ${MYSQL_CONFIG}
elif [ ${DIST} = "DEBIAN" ]; then
echo "
[server]

[mysqld]
user    = mysql
pid-file  = /var/run/mysqld/mysqld.pid
socket    = /var/run/mysqld/mysqld.sock
port    = 3306
basedir   = /usr
datadir   = /var/lib/mysql
tmpdir    = /tmp
lc-messages-dir = /usr/share/mysql
skip-external-locking
max_connections = 500
key_buffer_size   = 64M
max_allowed_packet  = 64M
thread_stack    = 1M
thread_cache_size       = 8
query_cache_limit = 8M
query_cache_size        = 64M
log_error = /var/log/mysql/error.log
expire_logs_days  = 10
max_binlog_size   = 1G
secure-file-priv = ""
symbolic-links=0
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
tmp_table_size=128MB
open_files_limit=500000

[embedded]

[mariadb]

[mariadb-10.1]
" > ${MYSQL_CONFIG}
fi;

startup_services

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -32- Installing Viaset Mysql Database from Script";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

MBillingMysqlPass=$(genpasswd)

mysql -uroot -p${password} -e "create database mbilling;"
mysql -uroot -p${password} -e "CREATE USER 'mbillingUser'@'localhost' IDENTIFIED BY '${MBillingMysqlPass}';"
mysql -uroot -p${password} -e "GRANT ALL PRIVILEGES ON \`mbilling\` . * TO 'mbillingUser'@'localhost' WITH GRANT OPTION;FLUSH PRIVILEGES;"    
mysql -uroot -p${password} -e "GRANT FILE ON * . * TO  'mbillingUser'@'localhost' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;"
if [ ${DIST} = "DEBIAN" ]; then
mysql -uroot -p${password} -e "update mysql.user set plugin='' where User='root';"
fi;
mysql mbilling -u root -p${password}  < /var/www/html/mbilling/script/database.sql

sleep 2
echo
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo "";
echo " -33- Updating Mysql Config Files";
echo "";
echo -e "\e[32;42m=================================================================================\e[m";
echo -e "\e[32;42m=================================================================================\e[m";
echo

echo "[general]
dbhost = 127.0.0.1
dbname = mbilling
dbuser = mbillingUser
dbpass = $MBillingMysqlPass
" > /etc/asterisk/res_config_mysql.conf
