#!/bin/bash
source /opt/dhis-integration/etc/application.yml
set -x

USER=bahmni
GROUP=bahmni

id -g ${GROUP} 2>/dev/null
if [ $? -eq 1 ]; then
    groupadd ${GROUP}
fi

id ${USER} 2>/dev/null
if [ $? -eq 1 ]; then
    useradd -g ${USER} ${USER}
fi

openmrs_db_url=$(grep -A1 'dhis.password:' /opt/dhis-integration/etc/application.yml | tail -n1); db=${db//*openmrs.db.url: /};
query_string=$(echo "$openmrs_db_url" | grep -o '?[^ ]*');
db_user=$(echo "$query_string" | sed -n 's/.*[?&]user=\([^&]*\).*/\1/p');
db_password=$(echo "$query_string" | sed -n 's/.*[?&]password=\([^&]*\).*/\1/p');


mysql --user="root" --password="P@ssw0rd" --database="openmrs" --execute="CREATE table dhis2_log ( 
																		id INT(6) unsigned auto_increment primary key, 
																		report_name varchar(100) not null, 
																		submitted_date timestamp, 
																		submitted_by varchar(30) not null, 
																		report_log varchar(4000) not null, 
																		status varchar(30) not null,
																		comment varchar(500) not null, 
																		report_month integer, 
																		report_year integer);"

mysql --user="root" --password="P@ssw0rd" --database="openmrs" --execute="create table dhis2_schedules (id int not null auto_increment, report_name varchar(255), frequency varchar(255), created_by varchar(255), created_date date, target_time datetime,last_run datetime, status varchar(255), enabled boolean, primary key(id));"

usermod -s /usr/sbin/nologin bahmni

mkdir -p /opt/dhis-integration/var/log/
mkdir /etc/dhis-integration/
mkdir /var/log/dhis-integration/
mkdir /dhis-integration/
mkdir /dhis-integration-data/
mkdir /var/www/bahmni_config/dhis2/

chown -R bahmni:bahmni /opt/dhis-integration/
chown -R bahmni:bahmni /dhis-integration/
chown -R bahmni:bahmni /dhis-integration-data/
chown -R bahmni:bahmni /var/www/bahmni_config/dhis2/ 
chmod +x /opt/dhis-integration/bin/dhis-integration

mv /opt/dhis-integration/bin/dhis-integration*.jar /opt/dhis-integration/bin/dhis-integration.jar

ln -sf /opt/dhis-integration/etc/application.yml /etc/dhis-integration/dhis-integration.yml
ln -sf /opt/dhis-integration/etc/log4j.properties /etc/dhis-integration/log4j.properties
ln -sf /opt/dhis-integration/var/log/dhis-integration.log /var/log/dhis-integration/dhis-integration.log
ln -sf /opt/dhis-integration/bin/dhis-integration /etc/init.d/dhis-integration



chkconfig --add dhis-integration