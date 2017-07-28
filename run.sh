#!/bin/sh

MYSQL_HOST=mysql
MYSQL_USERNAME=icinga2
MYSQL_PASSWORD=icinga2
MYSQL_ROOT_USERNAME=root
MYSQL_ROOT_PASSWORD=root
ICINGA2_DB_NAME=icinga2
ICINGA2WEB_DB_NAME=icingawebdb

INIT_FILE=/init.done

echo "\n****************** Icingaweb2 Token:\n"

cat /etc/icingaweb2/setup.token

if [ ! -f $INIT_FILE ]; then
     echo "\n****************** DB Schema Import:\n"
     
     sleep 10s

     mysql -h $MYSQL_HOST -u$MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS icinga2; GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icinga2.* TO 'icinga2'@'localhost' IDENTIFIED BY 'icinga2'; FLUSH PRIVILEGES;"

     mysql -h $MYSQL_HOST -u$MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD $ICINGA2_DB_NAME < /usr/share/icinga2-ido-mysql/schema/mysql.sql

     mysql -h $MYSQL_HOST -u$MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS icingawebdb; GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icingawebdb.* TO 'icingaweb'@'localhost' IDENTIFIED BY 'icingaweb'; FLUSH PRIVILEGES;"

     mysql -h $MYSQL_HOST -u$MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD $ICINGA2WEB_DB_NAME < /usr/share/icingaweb2/etc/schema/mysql.schema.sql

     mysql -h $MYSQL_HOST -u$MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD $ICINGA2WEB_DB_NAME -e "INSERT INTO icingaweb_user (name, active, password_hash) VALUES ('icingaadmin', 1, '\$1\$iQSrnmO9\$T3NVTu0zBkfuim4lWNRmH.');"

     echo "\n****************** Enable Icinga2web modules:\n"
     
     icingacli module enable monitoring
     icingacli module enable doc

     cat > /etc/icinga2/features-enabled/ido-mysql.conf <<END
     /**
      * The db_ido_mysql library implements IDO functionality
      * for MySQL.
      */

     library "db_ido_mysql"

     object IdoMysqlConnection "ido-mysql" {
        user = "$MYSQL_ROOT_USERNAME",
        password = "$MYSQL_ROOT_PASSWORD",
        host = "$MYSQL_HOST",
        database = "$ICINGA2_DB_NAME"
     }
END
     touch $INIT_FILE
fi

echo "\n******************* Restart Icinga2 Service:\n"

service icinga2 restart

echo "\n******************* Restart Apache2 Service:\n"

service apache2 restart

echo "\n******************* Print logs:\n"

tail -f /var/log/icinga2/*.log
