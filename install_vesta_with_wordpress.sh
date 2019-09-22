#!/bin/bash
if [ -z "$1" ]
  then
    echo "Invalid domain."
    exit 1
fi

# Server

yum -y install yum-utils openssl
yum-config-manager --enable remi-php74
yum -y update

# VestaCP

curl -O http://vestacp.com/pub/vst-install.sh
bash vst-install.sh --interactive no --nginx yes --apache yes --phpfpm no --named yes --remi yes --vsftpd yes --proftpd no --iptables yes --fail2ban yes --quota no --exim yes --dovecot yes --spamassassin yes --clamav no --softaculous no --mysql yes --postgresql no --hostname $1 --email info@$1 -f >> isntall.log

# WP-CLI

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Install WordPress

export VESTA=/usr/local/vesta/
db=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 3 | head -n 1)
user=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 3 | head -n 1)
pass=$(openssl rand -base64 10)
/usr/local/vesta/bin/v-add-database admin $db $user $pass

cd /home/admin/web/$1/public_html
rm -f index.html robots.txt
passwp=$(openssl rand -base64 10)
wp core download --allow-root
wp core config --dbname=admin_$db --dbuser=admin_$user --dbpass=$pass --dbhost=localhost --dbprefix=wp_ --allow-root
wp core install --url=http://$1 --title=$1 --admin_user=admin --admin_password=$passwp --admin_email=info@$1 --allow-root

echo "WordPress"
echo "User: admin"
echo "Pass: $passwp"
