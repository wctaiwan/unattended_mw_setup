#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

if [ "$EUID" -ne 0 ]
	then echo "The setup script needs to be run as root"
	exit
fi

source passwords.sh # Get values for $MARIADB_ROOT_PASSWORD, $MW_DB_PASSWORD and $MW_ADMIN_PASSWORD

# Silently install Apache, PHP, php5-mysql and git
apt-get update
apt-get install --yes apache2 php5 php5-mysql git

# Install MariaDB with preconfigured passwords
echo "mysql-server-5.5 mysql-server/root_password password $MARIADB_ROOT_PASSWORD" | debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password $MARIADB_ROOT_PASSWORD" | debconf-set-selections
apt-get install --yes mariadb-server

# Pass the database password to MariaDB as a variable and run the database setup script
mysql -uroot -p$MARIADB_ROOT_PASSWORD -e "SET @mw_db_password='$MW_DB_PASSWORD'; source setup.sql;"

# Clone MediaWiki, the vendor repository and Vector
cd /var/www/html
git clone --depth 1 https://gerrit.wikimedia.org/r/p/mediawiki/core.git ./w
cd w
git clone --depth 1 https://gerrit.wikimedia.org/r/p/mediawiki/vendor.git
cd skins
git clone --depth 1 https://gerrit.wikimedia.org/r/p/mediawiki/skins/Vector.git
cd ..

# Run the MediaWiki install script
php maintenance/install.php --dbname mediawiki --dbuser mediawiki --dbpass $MW_DB_PASSWORD --scriptpath '/w' --pass $MW_ADMIN_PASSWORD 'Test wiki' admin
