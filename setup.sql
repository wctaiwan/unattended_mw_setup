-- Secure MariaDB
-- We already set a root password
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Setup MediaWiki user and database
SET @query = CONCAT("CREATE USER 'mediawiki'@'localhost' IDENTIFIED BY '", @mw_db_password, "'");
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
CREATE DATABASE mediawiki;
GRANT index, create, select, insert, update, delete, drop, alter, lock tables ON mediawiki.* TO 'mediawiki'@'localhost';

FLUSH PRIVILEGES;
