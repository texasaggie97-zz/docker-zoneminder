#!/bin/bash

cat /etc/hosts

RESULT=`mysqlshow --user=root --password=$ZM_DB_ROOT_PASSWORD -h $ZM_DB_HOST zm| grep -v Wildcard | grep -o zm`
if [ "$RESULT" == "zm" ]; then
    echo ZoneMinder database already exists
else
    mysql --user=root --password=$ZM_DB_ROOT_PASSWORD -h $ZM_DB_HOST < /usr/share/zoneminder/db/zm_create.sql
fi

echo "grant select,insert,update,delete,create,alter,index,lock tables on zm.* to '${ZM_DB_USER}' identified by '${ZM_DB_PASSWORD}';" | mysql --user=root --password=$ZM_DB_ROOT_PASSWORD -h $ZM_DB_HOST


set -e

sed -ri "s/^;date.timezone\s*=/date.timezone =/g" /etc/php/7.1/apache2/php.ini
sed -ri "s:^date.timezone\s*=.*:date.timezone = ${TZ}:g" /etc/php/7.1/apache2/php.ini

sed -ri "s/^ZM_DB_HOST\s*=\s*localhost/ZM_DB_HOST=${ZM_DB_HOST}/g" /etc/zm/zm.conf
sed -ri "s/^ZM_DB_USER\s*=\s*zmuser/ZM_DB_USER=${ZM_DB_USER}/g" /etc/zm/zm.conf
sed -ri "s/^ZM_DB_PASS\s*=\s*zmpass/ZM_DB_PASS=${ZM_DB_PASSWORD}/g" /etc/zm/zm.conf

PHP_ERROR_REPORTING=${PHP_ERROR_REPORTING:-"E_ALL"}
sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php/7.1/apache2/php.ini
sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php/7.1/cli/php.ini
sed -ri "s/^error_reporting\s*=.*$//g" /etc/php/7.1/apache2/php.ini
sed -ri "s/^error_reporting\s*=.*$//g" /etc/php/7.1/cli/php.ini
echo "error_reporting = $PHP_ERROR_REPORTING" >> /etc/php/7.1/apache2/php.ini
echo "error_reporting = $PHP_ERROR_REPORTING" >> /etc/php/7.1/cli/php.ini

source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND
