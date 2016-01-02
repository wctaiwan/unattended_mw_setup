#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

source passwords.sh

apt-get update
apt-get install -y apache2 php5 php5-mysql git

echo "mysql-server-5.5 mysql-server/root_password password $MARIADB_ROOT_PASSWORD" | debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password $MARIADB_ROOT_PASSWORD" | debconf-set-selections
apt-get install -y mariadb-server

mysql -uroot -p$MARIADB_ROOT_PASSWORD -e "SET @mw_db_password='$MW_DB_PASSWORD'; source setup.sql;"

cd /var/www/html
git clone https://gerrit.wikimedia.org/r/p/mediawiki/core.git
mv core w
cd w
git clone https://gerrit.wikimedia.org/r/p/mediawiki/vendor.git
cd skins
git clone https://gerrit.wikimedia.org/r/p/mediawiki/skins/Vector.git
cd ..

php maintenance/install.php --dbname mediawiki --dbuser mediawiki --dbpass $MW_DB_PASSWORD --scriptpath '/w' --pass $MW_ADMIN_PASSWORD 'Test wiki' admin
