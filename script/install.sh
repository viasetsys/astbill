#!/bin/bash
clear
echo
echo
echo
echo -e "\e[1;42m===================== BY WWW.MAGNUSSOLUTION.COM =====================\e[m";
echo -e "\e[5m _      _                               ______ _ _ _ _               \e[m";
echo -e "\e[5m |\    /|                               | ___ (_) | (_)              \e[m";
echo -e "\e[5m | \  / | ___  ____  _ __  _   _  _____ | |_/ /_| | |_ _ __   ____   \e[m";
echo -e "\e[5m |  \/  |/   \/  _ \| '_ \| | | \| ___| | ___ \ | | | | '_ \ /  _ \  \e[m";
echo -e "\e[5m | |\/| |  | |  (_| | | | | |_| ||____  | |_/ / | | | | | | |  (_| | \e[m";
echo -e "\e[5m |_|  |_|\___|\___  |_| | |_____|_____|  \___/|_|_|_|_|_| |_|\___  | \e[m";
echo -e "\e[5m                 _/ |                                           _/ | \e[m";
echo -e "\e[5m                |__/                                           |__/  \e[m";
echo -e "\e[5m                                                                     \e[m";
echo -e "\e[1;42m======================= VOIP SYSTEM FOR LINUX =======================\e[m";
echo


sleep 3


if [[ -f /var/www/html/mbilling/index.php ]]; then
  echo "this server already has MagnusBilling installed";
  exit;
fi

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -1- Getting Linux Distribution and Setting Directories";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

# Linux Distribution CentOS or Debian
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
    echo -e "\e[32;42m======================================================================\e[m";
    echo -e "\e[32;42m======================================================================\e[m";
    echo "";
    echo " -2- Restart MySql, Apache, Asterisk and Setting Time-Zone";
    echo "";
    echo -e "\e[32;42m======================================================================\e[m";
    echo -e "\e[32;42m======================================================================\e[m";
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

set_timezone ()
{ 
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
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -3- Generating Mysql Password";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
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
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -4- Generated new Mysql password and stored in /root/passwordMysql.log";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -5- Disabling Selinux, Setting Mariadb Repo";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

if  [ ${DIST} = "CENTOS" ]; then
    sed 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config > borra && mv -f borra /etc/selinux/config
fi
if [ ${DIST} = "CENTOS" ]; then
echo '[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1' > /etc/yum.repos.d/MariaDB.repo 
fi


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -6- Install Magnus Billing Dependencies";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
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
    yum -y install kernel-devel.`uname -m` epel-release
    yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    yum -y install yum-utils gcc.`uname -m` gcc-c++.`uname -m` make.`uname -m` git.`uname -m` wget.`uname -m` bison.`uname -m` openssl-devel.`uname -m` ncurses-devel.`uname -m` doxygen.`uname -m` newt-devel.`uname -m` mlocate.`uname -m` lynx.`uname -m` tar.`uname -m` wget.`uname -m` nmap.`uname -m` bzip2.`uname -m` mod_ssl.`uname -m` speex.`uname -m` speex-devel.`uname -m` unixODBC.`uname -m` unixODBC-devel.`uname -m` libtool-ltdl.`uname -m` sox libtool-ltdl-devel.`uname -m` flex.`uname -m` screen.`uname -m` autoconf automake libxml2.`uname -m` libxml2-devel.`uname -m` sqlite* subversion
    yum-config-manager --enable remi-php71
    yum -y install php.`uname -m` php-cli.`uname -m` php-devel.`uname -m` php-gd.`uname -m` php-mbstring.`uname -m` php-pdo.`uname -m` php-xml.`uname -m` php-xmlrpc.`uname -m` php-process.`uname -m` php-posix libuuid uuid uuid-devel libuuid-devel.`uname -m`
    yum -y install jansson.`uname -m` jansson-devel.`uname -m` unzip.`uname -m` ntpd ntp
    yum -y install mysql mariadb-server  mariadb-devel mariadb php-mysql mysql-connector-odbc
    yum -y install xmlstarlet libsrtp libsrtp-devel dmidecode gtk2-devel binutils-devel svn libtermcap-devel libtiff-devel audiofile-devel cronie cronie-anacron
    yum -y install perl perl-libwww-perl perl-LWP-Protocol-https perl-JSON cpan flac libcurl-devel nss
    yum -y install libpcap-devel autoconf automake git ncurses-devel ssmtp htop
fi

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -7- Downloading MagnusBilling from Source and Extracting";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

mkdir -p /var/www/html/mbilling
cd /var/www/html/mbilling
wget  --no-check-certificate https://raw.githubusercontent.com/magnussolution/magnusbilling7/source/build/MagnusBilling-current.tar.gz
tar xzf MagnusBilling-current.tar.gz

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -8- Installing Jansson 2.7 for Asterisk";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

cd /usr/src
wget --no-check-certificate http://www.digip.org/jansson/releases/jansson-2.7.tar.gz
tar -zxvf jansson-2.7.tar.gz
cd jansson-2.7
./configure
make clean
make && make install
ldconfig

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -9- Installing Asterisk 13.35 from Magnus Source";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

cd /usr/src
rm -rf asterisk*
clear
mv /var/www/html/mbilling/script/asterisk-13.35.0.tar.gz /usr/src/
tar -xzvf asterisk-13.35.0.tar.gz
rm -rf asterisk-13.35.0.tar.gz
cd asterisk-*
useradd -c 'Asterisk PBX' -d /var/lib/asterisk asterisk
mkdir /var/run/asterisk
mkdir /var/log/asterisk
chown -R asterisk:asterisk /var/run/asterisk
chown -R asterisk:asterisk /var/log/asterisk
make clean
contrib/scripts/install_prereq install
./configure
make menuselect.makeopts
menuselect/menuselect --enable res_config_mysql  menuselect.makeopts
menuselect/menuselect --enable format_mp3  menuselect.makeopts
menuselect/menuselect --enable codec_opus  menuselect.makeopts
menuselect/menuselect --enable codec_silk  menuselect.makeopts
menuselect/menuselect --enable codec_siren7  menuselect.makeopts
menuselect/menuselect --enable codec_siren14  menuselect.makeopts
contrib/scripts/get_mp3_source.sh
make
make install
make samples
make config
ldconfig

clear

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -10- Installing SNGrep";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo


if [ ${DIST} = "DEBIAN" ]; then
  apt-get -y install sngrep
fi


if [ ${DIST} = "CENTOS" ]; then
cd /usr/src
git clone https://github.com/irontec/sngrep.git
cd sngrep
./bootstrap.sh
./configure
make && make install 
clear
fi

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -11- Changed tmp folder Permission to 777";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

chmod -R 777 /tmp

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -12- Downloading and Extracting mpg123-12.20.1 ----IMPORTANT----";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -13- Updating deflate.conf and expire.conf in httpd directory";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

if [ ${DIST} = "CENTOS" ]; then
    cd /usr/src
    wget --no-check-certificate http://magnussolution.com/download/mpg123-1.20.1.tar.bz2
    tar -xjvf mpg123-1.20.1.tar.bz2
    cd mpg123-1.20.1
    ./configure && make && make install

    echo "
    <IfModule mod_deflate.c>
      AddOutputFilterByType DEFLATE text/plain
      AddOutputFilterByType DEFLATE text/html
      AddOutputFilterByType DEFLATE text/xml
      AddOutputFilterByType DEFLATE text/css
      AddOutputFilterByType DEFLATE text/javascript
      AddOutputFilterByType DEFLATE image/svg+xml
      AddOutputFilterByType DEFLATE image/x-icon
      AddOutputFilterByType DEFLATE application/xml
      AddOutputFilterByType DEFLATE application/xhtml+xml
      AddOutputFilterByType DEFLATE application/rss+xml
      AddOutputFilterByType DEFLATE application/javascript
      AddOutputFilterByType DEFLATE application/x-javascript
      DeflateCompressionLevel 9
      BrowserMatch ^Mozilla/4 gzip-only-text/html
      BrowserMatch ^Mozilla/4\.0[678] no-gzip
      BrowserMatch \bMSIE !no-gzip !gzip-only-text/html
      BrowserMatch \bOpera !no-gzip
      DeflateFilterNote Input instream
      DeflateFilterNote Output outstream
      DeflateFilterNote Ratio ratio
      LogFormat '\"%r\" %{outstream}n/%{instream}n (%{ratio}n%%)' deflate
    </IfModule>
    " >> /etc/httpd/conf.d/deflate.conf
	
	echo "
    <IfModule mod_expires.c>
     ExpiresActive On
     ExpiresByType image/jpg \"access plus 60 days\"
     ExpiresByType image/png \"access plus 60 days\"
     ExpiresByType image/gif \"access plus 60 days\"
     ExpiresByType image/jpeg \"access plus 60 days\"
     ExpiresByType text/css \"access plus 1 days\"
     ExpiresByType image/x-icon \"access plus 1 month\"
     ExpiresByType application/pdf \"access plus 1 month\"
     ExpiresByType audio/x-wav \"access plus 1 month\"
     ExpiresByType audio/mpeg \"access plus 1 month\"
     ExpiresByType video/mpeg \"access plus 1 month\"
     ExpiresByType video/mp4 \"access plus 1 month\"
     ExpiresByType video/quicktime \"access plus 1 month\"
     ExpiresByType video/x-ms-wmv \"access plus 1 month\"
     ExpiresByType application/x-shockwave-flash \"access 1 month\"
     ExpiresByType text/javascript \"access plus 1 week\"
     ExpiresByType application/x-javascript \"access plus 1 week\"
     ExpiresByType application/javascript \"access plus 1 week\"
    </IfModule>
    " >> /etc/httpd/conf.d/expire.conf
fi


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -14- Setting HTTP access permissions";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo '
<IfModule mime_module>
AddType application/octet-stream .csv
</IfModule>

<Directory "/var/www/html">
    DirectoryIndex index.htm index.html index.php index.php3 default.html index.cgi
</Directory>


<Directory "/var/www/html/mbilling/protected">
    deny from all
</Directory>

<Directory "/var/www/html/mbilling/yii">
    deny from all
</Directory>

<Directory "/var/www/html/mbilling/doc">
    deny from all
</Directory>

<Directory "/var/www/html/mbilling/resources/*log">
    deny from all
</Directory>

<Files "*.sql">
  deny from all
</Files>

<Files "*.log">
  deny from all
</Files>
' >> ${HTTP_CONFIG}

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -15- Updating PHP.ini file";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

rm -rf ${PHP_INI}_old
cp -rf ${PHP_INI} ${PHP_INI}_old

sed -i "s/memory_limit = 16M/memory_limit = 512M /" ${PHP_INI}
sed -i "s/memory_limit = 128M/memory_limit = 512M /" ${PHP_INI} 
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 3M /" ${PHP_INI}
sed -i "s/post_max_size = 8M/post_max_size = 20M/" ${PHP_INI}
sed -i "s/max_execution_time = 30/max_execution_time = 90/" ${PHP_INI}
sed -i "s/max_input_time = 60/max_input_time = 120/" ${PHP_INI}
if [ ${DIST} = "CENTOS" ]; then
    sed -i "s/User apache/User asterisk/" ${HTTP_CONFIG}
    sed -i "s/Group apache/Group asterisk/" ${HTTP_CONFIG}
elif [ ${DIST} = "DEBIAN" ]; then
    sed -i 's/User ${APACHE_RUN_USER}/User asterisk/' ${HTTP_CONFIG}
    sed -i 's/Group ${APACHE_RUN_GROUP}/Group asterisk/' ${HTTP_CONFIG}
    mkdir -p /var/www/html
    sed -i 's/<Directory \/var\/www\/>/<Directory \/var\/www\/html\/>/' ${HTTP_CONFIG}
fi; 

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo "--15.1-- Created mysql password: Your mysql root password is $password ----";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -16- Enabling and Restarting HTTPD and Mariadb";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo


if [ ${DIST} = "DEBIAN" ]; then
    systemctl enable apache2    
else [ -f /etc/redhat-release ]
    systemctl enable httpd
fi

systemctl enable mariadb
systemctl start mariadb
systemctl enable ntpd

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -17- Setting Mysql root password to $password";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

mysql -uroot -e "UPDATE mysql.user SET password=PASSWORD('${password}') WHERE user='root'; FLUSH PRIVILEGES;"


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -18- Updating Mysql Config in my.cnf";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
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
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -19- Installing Web Interface";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo
if [ ${DIST} = "DEBIAN" ]; then
    rm -rf /var/www/html/index.html
fi;

cd  /var/www/html/mbilling/resources/images/
rm -rf lock-screen-background.jpg
wget --no-check-certificate https://magnusbilling.org/download/lock-screen-background.jpg

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -20- Updating Permissions for MagnusBilling User = Asterisk";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

cd /var/www/html/mbilling/
rm -rf /var/www/html/mbilling/tmp && mkdir /var/www/html/mbilling/tmp
mkdir /var/www/html/mbilling/assets
chown -R asterisk:asterisk /var/www/html/mbilling
mkdir /var/run/magnus
touch /etc/asterisk/extensions_magnus.conf
touch /etc/asterisk/extensions_magnus_did.conf
touch /etc/asterisk/sip_magnus_register.conf
touch /etc/asterisk/sip_magnus.conf
touch /etc/asterisk/sip_magnus_user.conf
touch /etc/asterisk/iax_magnus_register.conf
touch /etc/asterisk/iax_magnus.conf
touch /etc/asterisk/iax_magnus_user.conf
touch /etc/asterisk/musiconhold_magnus.conf
touch /etc/asterisk/queues_magnus.conf


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -21- Asterisk Language Selection";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

selectLanguage() {
   echo "SELECT THE MAIN LANGUAGE"  
   echo "------------------------------------------"
   echo "Options:"
   echo
   echo "1. Portuguese"
   echo "2. English"
   echo "3. Spanish"
   echo
   echo -n "Select one option: "
   read opcao
   case $opcao in
      1) installBr;;
      2) installEn;;
      3) installEs;;
      *) "Invalid option." ; echo ; selectLanguage ;;
   esac
}

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -22- Copying MagnusBilling Sound Files to Asterisk";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

cp -rf /var/www/html/mbilling/resources/sounds/br /var/lib/asterisk/sounds
cp -rf /var/www/html/mbilling/resources/sounds/es /var/lib/asterisk/sounds
cp -rf /var/www/html/mbilling/resources/sounds/en /var/lib/asterisk/sounds

installBr() {
   clear
   language='br'
   cd /var/lib/asterisk
   wget https://sourceforge.net/projects/disc-os/files/Disc-OS%20Sounds/1.0-RELEASE/Disc-OS-Sounds-1.0-pt_BR.tar.gz
   tar xzf Disc-OS-Sounds-1.0-pt_BR.tar.gz
   rm -rf Disc-OS-Sounds-1.0-pt_BR.tar.gz

   cp -n /var/lib/asterisk/sounds/pt_BR/*  /var/lib/asterisk/sounds/br
   rm -rf /var/lib/asterisk/sounds/pt_BR
   mkdir -p /var/lib/asterisk/sounds/br/digits
   cp -rf /var/lib/asterisk/sounds/digits/pt_BR/* /var/lib/asterisk/sounds/br/digits
   cp -n /var/www/html/mbilling/resources/sounds/br/* /var/lib/asterisk/sounds
}

installEn() {
    clear
    language='en'
    cp -n /var/www/html/mbilling/resources/sounds/en/* /var/lib/asterisk/sounds
}

installEs() {
  clear
  language='es'
  mkdir -p /var/lib/asterisk/sounds/es
  cd /var/lib/asterisk/sounds/es
  wget -O core.zip http://www.asterisksounds.org/es-ar/download/asterisk-sounds-core-es-AR-sln16.zip
  wget -O extra.zip http://www.asterisksounds.org/es-ar/download/asterisk-sounds-extra-es-AR-sln16.zip
  unzip core.zip
  unzip extra.zip
  chown -R asterisk.asterisk /var/lib/asterisk/sounds/es
  cp -n /var/www/html/mbilling/resources/sounds/es/* /var/lib/asterisk/sounds
}


if [[ $1 == '' ]]; then
  selectLanguage
elif [[ $1 == 'en' ]]; then
  installEn
elif [[ $1 == 'br' ]]; then
  installBr
elif [[ $1 == 'es' ]]; then
  installEs
else
  selectLanguage
fi


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -23- Updating MagnusBilling DialPlan";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

cd /var/www/html/mbilling

echo $'[billing]
exten => _[*0-9].,1,AGI("/var/www/html/mbilling/resources/asterisk/mbilling.php")
  same => n,Hangup()

exten => _+X.,1,Goto(billing,${EXTEN:1},1)

exten => h,1,hangup()

exten => *111,1,VoiceMailMain(${CHANNEL(peername)}@billing)
  same => n,Hangup()

[trunk_answer_handler]
exten => s,1,Set(MASTER_CHANNEL(TRUNKANSWERTIME)=${EPOCH})
  same => n,Return()

' > /etc/asterisk/extensions_magnus.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -24- Updating Asterisk Manager Config";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "
[general]
enabled = yes

port = 5038
bindaddr = 0.0.0.0
displayconnects = no

[magnus]
secret = magnussolution
deny=0.0.0.0/0.0.0.0
permit=127.0.0.1/255.255.255.0
read = system,call,log,verbose,agent,user,config,dtmf,reporting,cdr,dialplan
write = system,call,agent,user,config,command,reporting,originate
" > /etc/asterisk/manager.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -25- Including MagnusBilling Extensions and MOH Config in Asterisk";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "#include extensions_magnus.conf" >> /etc/asterisk/extensions.conf
echo '#include extensions_magnus_did.conf' >> /etc/asterisk/extensions.conf
echo "#include musiconhold_magnus.conf" >> /etc/asterisk/musiconhold.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -26- Setting Voicemail Config";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "[settings]
voicemail => mysql,general,pkg_voicemail_users
" > /etc/asterisk/extconfig.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -27- Including Modules in Asterisk Modules.conf";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "
noload => res_config_sqlite3.so
noload => res_config_sqlite.so
noload => chan_skinny.so
noload => cdr_custom.so
noload => cdr_odbc.so
noload => cdr_sqlite3_custom.so
noload => cdr_csv.so
noload => cdr_manager.so
noload => chan_iax2.so
noload => cdr_mysql.so
noload => app_celgenuserevent.so
noload => cel_custom.so
noload => cel_manager.so
noload => cel_odbc.so
noload => cel_sqlite3_custom.so
noload => res_format_attr_celt.so
" >> /etc/asterisk/modules.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -28- Including Log Retain files in Asterisk";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "
/var/log/asterisk/*log {
  missingok
  rotate 3
  weekly
  postrotate
  /usr/sbin/asterisk -rx 'logger reload' > /dev/null 2> /dev/null
  endscript
}

/var/log/asterisk/messages {
  missingok
  rotate 3
  weekly
  postrotate
  /usr/sbin/asterisk -rx 'logger reload' > /dev/null 2> /dev/null
  endscript
}

/var/log/asterisk/magnus {
  missingok
  rotate 3
  daily
  postrotate
  /usr/sbin/asterisk -rx 'logger reload' > /dev/null 2> /dev/null
  endscript
}

/var/log/asterisk/fail2ban {
  missingok
  rotate 3
  weekly
  postrotate
  /usr/sbin/asterisk -rx 'logger reload' > /dev/null 2> /dev/null
  endscript
}
" > /etc/logrotate.d/asterisk


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -29- Installing MagnusBilling Mysql Database from Script";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
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
rm -rf /var/www/html/mbilling/script

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -30- Updating Mysql Config Files";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "[general]
dbhost = 127.0.0.1
dbname = mbilling
dbuser = mbillingUser
dbpass = $MBillingMysqlPass
" > /etc/asterisk/res_config_mysql.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -31- Updating Data Directories in asterisk.conf";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo '[directories](!)
astetcdir => /etc/asterisk
astmoddir => /usr/lib/asterisk/modules
astvarlibdir => /var/lib/asterisk
astdbdir => /var/lib/asterisk
astkeydir => /var/lib/asterisk
astdatadir => /var/lib/asterisk
astagidir => /var/lib/asterisk/agi-bin
astspooldir => /var/spool/asterisk
astrundir => /var/run/asterisk
astlogdir => /var/log/asterisk

[options]
documentation_language = en_US  
' > /etc/asterisk/asterisk.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -32- Adding Asterisk options verbose=5, debug=0 and maxfiles=500000";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo


echo "
[options]
verbose = 5
debug = 0
maxfiles = 500000

[compat]
pbx_realtime=1.6
res_agi=1.6
app_set=1.6" >> /etc/asterisk/asterisk.conf


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -33- Updating Max File Limits in Proc and sysctl.conf";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo 500000 > /proc/sys/fs/file-max
echo "fs.file-max=500000">>/etc/sysctl.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -34- Setting Security and File Limits in limits.conf";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo '
* soft nofile 500000
* hard nofile 500000
* soft core unlimited
* hard core unlimited
* soft data unlimited
* hard data unlimited
* soft fsize unlimited
* hard fsize unlimited
* soft memlock unlimited
* hard memlock unlimited
* soft cpu unlimited
* hard cpu unlimited
* soft nproc unlimited
* hard nproc unlimited
* soft locks unlimited
* hard locks unlimited
* soft sigpending unlimited
* hard sigpending unlimited' >> /etc/security/limits.conf


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -35- Adding new CronJobs for MagnusBilling";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo


if [ ${DIST} = "DEBIAN" ]; then
    CRONPATH='/var/spool/cron/crontabs/root'
elif [ ${DIST} = "CENTOS" ]; then
    CRONPATH='/var/spool/cron/root'
fi

echo "
8 8 * * * php /var/www/html/mbilling/cron.php servicescheck
* * * * * php /var/www/html/mbilling/cron.php callchart
1 * * * * php /var/www/html/mbilling/cron.php NotifyClient
1 22 * * * php /var/www/html/mbilling/cron.php DidCheck
1 23 * * * php /var/www/html/mbilling/cron.php PlanCheck
* * * * * php /var/www/html/mbilling/cron.php MassiveCall
* * * * * php /var/www/html/mbilling/cron.php Sms
0 2 * * * php /var/www/html/mbilling/cron.php Backup
0 4 * * * /var/www/html/mbilling/protected/commands/clear_memory
*/2 * * * * php /var/www/html/mbilling/cron.php SummaryTablesCdr
* * * * * php /var/www/html/mbilling/cron.php cryptocurrency
*/3 * * * * php /var/www/html/mbilling/cron.php PhoneBooksReprocess
* * * * * php /var/www/html/mbilling/cron.php statussystem
* * * * * php /var/www/html/mbilling/cron.php didwww
" > $CRONPATH
chmod 600 $CRONPATH
crontab $CRONPATH

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -36- Updating sip.conf file in Asterisk";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "
[general]
bindaddr=0.0.0.0
bindport=5060
context = billing
dtmfmode=RFC2833
disallow=all
allow=g729
allow=g723
allow=ulaw  
allow=alaw  
allow=gsm
rtcachefriends=yes
srvlookup=yes
useragent=MagnusBilling
allowsubscribe = no
alwaysauthreject=yes
rtupdate=yes
allowguest=no
language=$language
rtptimeout=60
rtpholdtimeout=300
rtsavesysname=yes
rtupdate=yes
ignoreregexpire=yes

#include sip_magnus_register.conf
#include sip_magnus_user.conf
#include sip_magnus.conf
" > /etc/asterisk/sip.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -37- Updating iax.conf file in Asterisk";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo


echo "
[general]
bandwidth=low
disallow=lpc10
jitterbuffer=no
autokill=yes

#include iax_magnus_register.conf
#include iax_magnus_user.conf
#include iax_magnus.conf
" > /etc/asterisk/iax.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -38- Updating queues.conf per Mbilling";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "
#include queues_magnus.conf
" >> /etc/asterisk/queues.conf


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -39- Creating index.php and robots.txt in /var/www/html/ for Mbilling";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo


echo "<?php 
header('Location: ./mbilling');
?>
" > /var/www/html/index.php

echo "
User-agent: *
Disallow: /mbilling/
" > /var/www/html/robots.txt

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -40- Installing Fail2Ban and IP-Tables";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

systemctl daemon-reload

install_fail2ban()
{
  if [ ${DIST} = "CENTOS" ]; then
    yum install -y iptables-services

    rm -rf /etc/fail2ban
    cd /tmp
    git clone https://github.com/fail2ban/fail2ban.git
    cd /tmp/fail2ban
    python setup.py install


    systemctl mask firewalld.service
    systemctl enable iptables.service
    systemctl enable ip6tables.service
    systemctl stop firewalld.service
    systemctl start iptables.service
    systemctl start ip6tables.service
    systemctl enable iptables
    systemctl stop firewalld
    chkconfig --levels 123456 firewalld off
  fi      
  if [ ${DIST} = "DEBIAN" ]; then
    apt-get -y install fail2ban
  fi 
      
}


echo
echo "Installing Fail2ban & Iptables"
echo


install_fail2ban

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -41- Updating IP-Tables Rules";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

iptables -F
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -p udp -m udp --dport 5060 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 10000:20000 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "friendly-scanner" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "sundayddr" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "sipsak" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "sipvicious" --algo bm
iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "iWar" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5060 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5060 -m string --string "VaxSIPUserAgent/" --algo bm


if [ ${DIST} = "DEBIAN" ]; then
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
    apt-get install -y --force-yes  iptables-persistent
elif [ ${DIST} = "CENTOS" ]; then
    service iptables save
    systemctl restart iptables
fi


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -42- Updating permissions for /mbilling/protected/runtime Directory";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

touch /var/www/html/mbilling/protected/runtime/application.log
chmod 655 /var/www/html/mbilling/protected/runtime/application.log

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -43- Configuring Fail2Ban for Overall Security";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo
echo "Fail2ban configuration!"
echo

echo '
Defaults!/usr/bin/fail2ban-client !requiretty
asterisk ALL=(ALL) NOPASSWD: /usr/bin/fail2ban-client
' >> /etc/sudoers



echo '
[INCLUDES]
[Definition]
failregex = NOTICE.* .*: Useragent: sipcli.*\[<HOST>\] 
ignoreregex =
' > /etc/fail2ban/filter.d/asterisk_cli.conf

echo '
[INCLUDES]
[Definition]
failregex = .*NOTICE.* <HOST> tried to authenticate with nonexistent user.*
ignoreregex =
' > /etc/fail2ban/filter.d/asterisk_manager.conf

echo '
[INCLUDES]
[Definition]
failregex = NOTICE.* .*hangupcause to DB: 200, \[<HOST>\]
ignoreregex =
' > /etc/fail2ban/filter.d/asterisk_hgc_200.conf

echo '
[INCLUDES]
[Definition]
failregex = .*client <HOST>\].*request failed: URI too long.*
     .*client <HOST>\].*request failed: error reading the headers
ignoreregex =
' > /etc/fail2ban/filter.d/mbilling_ddos.conf

echo '
[INCLUDES]
[Definition]
failregex = .* Username or password is wrong - User .* from IP - <HOST>
ignoreregex =
' > /etc/fail2ban/filter.d/mbilling_login.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -44- Updating jail.local";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "
[DEFAULT]
ignoreip = 127.0.0.1
bantime  = 600
findtime  = 600
maxretry = 3
backend = auto
usedns = warn


[asterisk-iptables]   
enabled  = true           
filter   = asterisk       
action   = iptables-allports[name=ASTERISK, port=all, protocol=all]   
logpath  = /var/log/asterisk/messages 
maxretry = 5  
bantime = 600

[ast-cli-attck]   
enabled  = true           
filter   = asterisk_cli     
action   = iptables-allports[name=AST_CLI_Attack, port=all, protocol=all]
logpath  = /var/log/asterisk/messages 
maxretry = 1  
bantime = -1

[asterisk-manager]   
enabled  = true           
filter   = asterisk_manager     
action   = iptables-allports[name=AST_MANAGER, port=all, protocol=all]
logpath  = /var/log/asterisk/messages 
maxretry = 1  
bantime = -1

[ast-hgc-200]
enabled  = true           
filter   = asterisk_hgc_200     
action   = iptables-allports[name=AST_HGC_200, port=all, protocol=all]
logpath  = /var/log/asterisk/messages
maxretry = 20
bantime = -1

[mbilling_login]
enabled  = true
filter   = mbilling_login
action   = iptables-allports[name=mbilling_login, port=all, protocol=all]
logpath  = /var/www/html/mbilling/protected/runtime/application.log
maxretry = 3
bantime = 600

[ip-blacklist]
enabled   = true
filter    = ip-blacklist
action    = iptables-allports[name=ASTERISK, protocol=all] 
logpath   = /var/www/html/mbilling/resources/ip.blacklist
maxretry  = 0
findtime  = 15552000
bantime   = -1
" > /etc/fail2ban/jail.local



if [ ${DIST} = "DEBIAN" ]; then
echo "
[sshd]
enablem=true

[mbilling_ddos]
enabled  = true
filter   = mbilling_ddos
action   = iptables-allports[name=mbilling_ddos, port=all, protocol=all]
logpath  = /var/log/apache2/error.log
maxretry = 20
bantime = 3600" >> /etc/fail2ban/jail.local
elif [ ${DIST} = "CENTOS" ]; then
echo "
[ssh-iptables]
enabled  = true
filter   = sshd
action   = iptables-allports[name=SSH, port=all, protocol=all]
logpath  = /var/log/secure
maxretry = 3
bantime = 600

[mbilling_ddos]
enabled  = true
filter   = mbilling_ddos
action   = iptables-allports[name=mbilling_ddos, port=all, protocol=all]
logpath  = /var/log/httpd/error_log
maxretry = 20
bantime = 3600
 " >> /etc/fail2ban/jail.local
fi


sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -45- Updating Security Rules in ip-blacklist.conf";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

rm -rf /var/www/html/mbilling/resources/ip.blacklist
touch /var/www/html/mbilling/resources/ip.blacklist
chown -R asterisk:asterisk /var/www/html/mbilling/resources/

echo "
[Definition]
failregex = ^<HOST> \[.*\]$
ignoreregex =
" > /etc/fail2ban/filter.d/ip-blacklist.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -46- Updating Log Rules in /etc/asterisk/logger.conf";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

echo "
[general]
dateformat=%F %T

[logfiles]
console => error
messages => notice,warning,error
magnus => debug
" > /etc/asterisk/logger.conf

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -47- Copying fail2ban.service to /usr/lib/systemd/system";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

if [ ${DIST} = "CENTOS" ]; then  
  cp -rf /tmp/fail2ban/build/fail2ban.service /usr/lib/systemd/system/fail2ban.service
fi

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -48- Creating and enabling Fail2Ban Service";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

mkdir /var/run/fail2ban/
asterisk -rx "module reload logger"
systemctl enable fail2ban.service 
systemctl restart fail2ban.service 
iptables -L -v

php /var/www/html/mbilling/cron.php updatemysql

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -49- Setting Permission for Directories required by Mbilling";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

chown -R asterisk:asterisk /var/lib/php/session*
chown -R asterisk:asterisk /var/spool/asterisk/outgoing/
chown -R asterisk:asterisk /etc/asterisk
chmod -R 777 /tmp
chmod -R 555 /var/www/html/mbilling/
chmod -R 750 /var/www/html/mbilling/resources/reports 
chmod -R 774 /var/www/html/mbilling/protected/runtime/
mkdir -p /usr/local/src/magnus/monitor
mkdir -p /usr/local/src/magnus/sounds
mkdir -p /usr/local/src/magnus/backup

mkdir -p /var/www/tmpmagnus
chown -R asterisk:asterisk /var/www/tmpmagnus
chmod -R 777 /var/www/tmpmagnus

mv /usr/local/src/backup* /usr/local/src/magnus/backup
chown -R asterisk:asterisk /usr/local/src/magnus/
chmod -R 755 /usr/local/src/magnus/

chmod 774 /var/www/html/mbilling/resources/ip.blacklist
chmod -R 655 /var/www/html/mbilling/tmp
chmod -R 750 /var/www/html/mbilling/resources/sounds
chmod -R 770 /var/www/html/mbilling/resources/images
chmod -R 755 /var/www/html/mbilling/assets/
chown -R asterisk:asterisk /var/www/html/mbilling
chmod +x /var/www/html/mbilling/resources/asterisk/mbilling.php
chmod -R 100 /var/www/html/mbilling/resources/asterisk/
chown -R asterisk:asterisk /var/lib/asterisk/moh/
echo
echo
echo ===============================================================
echo 

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -50- Downloading and Installing Codecs Based on CPUInfo";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

p4_proc()
{
    set $(grep "model name" /proc/cpuinfo);

    if [ "$4" == "Celeron" ]; then

        wget http://asterisk.hosting.lv/bin/codec_g723-ast14-gcc4-glibc-pentium.so   
        wget http://asterisk.hosting.lv/bin/codec_g729-ast14-gcc4-glibc-pentium.so
        cp /usr/src/codec_g723-ast14-gcc4-glibc-pentium.so /usr/lib/asterisk/modules/codec_g723.so
        cp /usr/src/codec_g729-ast14-gcc4-glibc-pentium.so /usr/lib/asterisk/modules/codec_g729.so
         
        return 0;
    fi

    wget http://asterisk.hosting.lv/bin/codec_g723-ast130-gcc4-glibc-pentium4.so   
    wget http://asterisk.hosting.lv/bin/codec_g729-ast130-gcc4-glibc-pentium4.so
    mv /usr/src/codec_g723-ast130-gcc4-glibc-pentium4.so  /usr/lib/asterisk/modules/codec_g723.so
    mv codec_g729-ast130-gcc4-glibc-pentium4.so /usr/lib/asterisk/modules/codec_g729.so            

}
p4_x64_proc()
{         
    wget http://asterisk.hosting.lv/bin/codec_g723-ast130-gcc4-glibc-x86_64-pentium4.so
    wget http://asterisk.hosting.lv/bin/codec_g729-ast130-gcc4-glibc-x86_64-pentium4.so
    mv /usr/src/codec_g723-ast130-gcc4-glibc-x86_64-pentium4.so /usr/lib/asterisk/modules/codec_g723.so
    mv /usr/src/codec_g729-ast130-gcc4-glibc-x86_64-pentium4.so /usr/lib/asterisk/modules/codec_g729.so
      
}
p3_proc()
{       
    set $(grep "model name" /proc/cpuinfo);
    if [ "$4" == "Intel(R)" &&  "$5" == "Pentium(R)" && "$6-e "\e[32;42m== "III" ];then
        wget http://asterisk.hosting.lv/bin/codec_g723-ast130-gcc4-glibc-pentium.so   
        wget http://asterisk.hosting.lv/bin/codec_g729-ast130-gcc4-glibc-pentium.so
        mv /usr/src/codec_g723-ast130-gcc4-glibc-pentium.so /usr/lib/asterisk/modules/codec_g723.so
        mv /usr/src/codec_g729-ast130-gcc4-glibc-pentium.so /usr/lib/asterisk/modules/codec_g729.so
        return 0;
    fi
    wget http://asterisk.hosting.lv/bin/codec_g723-ast130-gcc4-glibc-pentium3.so
    wget http://asterisk.hosting.lv/bin/codec_g729-ast130-gcc4-glibc-pentium3.so
    mv /usr/src/codec_g723-ast130-gcc4-glibc-pentium3.so /usr/lib/asterisk/modules/codec_g723.so
    mv /usr/src/codec_g729-ast130-gcc4-glibc-pentium3.so /usr/lib/asterisk/modules/codec_g729.so

}
AMD_proc()
{
    wget http://asterisk.hosting.lv/bin/codec_g729-ast130-gcc4-glibc-athlon-sse.so
    wget http://asterisk.hosting.lv/bin/codec_g723-ast130-gcc4-glibc-athlon-sse.so
    mv /usr/src/codec_g723-ast130-gcc4-glibc-athlon-sse.so /usr/lib/asterisk/modules/codec_g723.so
    mv /usr/src/codec_g729-ast130-gcc4-glibc-athlon-sse.so /usr/lib/asterisk/modules/codec_g729.so

}

processor_type()
{
    _UNAME=`uname -a`;
    _IS_64_BIT=`echo "$_UNAME"  | grep x86_64`
    if [ -n "$_IS_64_BIT" ];
        then _64BIT=1;
        else _64BIT=0;
    fi;
}
clear 
echo "INSTALLING G723 and G729 CODECS......... FROM http://asterisk.hosting.lv";   
cd /usr/src
rm -rf codec_*
processor_type;
    _IS_AMD=`cat /proc/cpuinfo | grep AMD`;
    _P3=`cat /proc/cpuinfo | grep "Pentium III"`;
    _P3_R=`cat /proc/cpuinfo | grep "Pentium(R) III"`;
    _INTEL=`cat /proc/cpuinfo | grep Intel`;
    if [ -n "$_IS_AMD" ];
      then 
          echo "Processor type detected: AMD";
          if  [ "$_64BIT" == 1 ]; then 
            echo "It is a x64 proc";
               p4_x64_proc;
          else 
            echo "AMD processor detected"; 
            AMD_proc;
          fi
       
    elif [ -n "$_P3_R" ]; then echo "Pentium(R) III processor detected"; p3_proc;           
    elif [ "$_64BIT" == 1 ]; then echo "Processor type detected: INTEL x64"; p4_x64_proc;       
    elif [ -n "$_INTEL" ]; then echo "Pentium IV processor detected"; p4_proc;
    elif [ -n "$_P3" ]; then echo "Pentium III processor detected"; p3_proc;
    else
        echo -e "Automatic detection of required codec installation script failed\nYou must manually select and install the required codec according to this output:";
        cat /proc/cpuinfo
        uname -a
        echo "you can find codecs installation scripts in http://asterisk.hosting.lv";
    fi;

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo " -51- Enabling Codecs G729 and G723 in Asterisk";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

asterisk -rx 'module load codec_g729.so'
asterisk -rx 'module load codec_g723.so'
sleep 4
asterisk -rx 'core show translation'

sleep 2
echo
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo "";
echo "Note: if codecs are not loaded successfully, Troubleshoot Asterisk";
echo "";
echo -e "\e[32;42m======================================================================\e[m";
echo -e "\e[32;42m======================================================================\e[m";
echo

whiptail --title "MagnusBilling Instalation Result" --msgbox "Congratulations! You have installed MagnusBilling in your Server.\n\nAccess your MagnusBilling in http://your_ip/ \n  Username = root \n  Password = magnus \n\nYour mysql root password is $password\n\n\nPRESS ANY KEY TO REBOOT YOUR SERVER" --fb 20 70

reboot
