#!/bin/bash

#This script will backup and update the ott-proxies.conf file. Once backup and update are complete it will validate the configuration and gracefully restart apache.

#create backup directory


if [ ! -d /var/app/comcast/data/backups/web/httpd/conf/ ]
    then

       echo "--INFO: directory already exists"
else
       echo "--INFO: directory does not exist, creating it"

       mkdir -p /var/app/comcast/data/backups/web/httpd/conf/
fi

#back up existing file

/bin/cp -p /etc/httpd/conf/ott-proxies.conf /var/app/comcast/data/backups/web/httpd/conf/ott-proxies.conf

if [ $? -ne 0 ]
   then
       echo "--ERROR: backup failed"
       exit 1
fi

echo "--INFO: completed backup of file"

#copy new file in place

/bin/cp -p /tmp/ott-proxies.conf /etc/httpd/conf/ott-proxies.conf

if [ $? -ne 0 ]
   then
       echo "--ERROR: copy of file failed"
       exit 1
fi

echo "--INFO: completed copying new file in place"

#run apache config test

/usr/sbin/apachectl configtest

if [ $? -ne 0 ]
   then
       echo "--ERROR: configtest failed"
       exit 1
fi

echo "--INFO: completed apache configtest"

# graceful restart 
/usr/sbin/apachectl graceful-stop ; while [ $(ps -ef | grep httpd | grep -v grep | wc -l) -ne 0 ]; do sleep 2; done ; service httpd restart

if [ $? -ne 0 ]
   then
       echo "--ERROR: graceful restart failed"
fi

echo "--INFO: completed graceful restart"
