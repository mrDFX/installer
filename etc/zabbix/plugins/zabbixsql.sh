#!/bin/bash
#set -x
# 															Check if MySQL is running and\or is autoloaded
if [ -z "$(pgrep mysqld)" ]
  then
    echo "MySQL is not running. Checking autoload."
    if [ ! -z "$(chkconfig --list | grep mysql | grep on)" ]
      then
	echo "MySQL is in autoload, but not running. Please start it if necessary and re-run the script"
	MYSQLEX=1
      else
	echo "MySQL is not running and not in autoload."
	MYSQLEX=0
    fi
  else
    echo "MySQL is running"
    MYSQLEX=1
fi
#															if Mysql root credentials are not recorded
if [ ! -f ~/.my.cnf ]
  then	#														ask for root password
    echo "MySQL password"
    stty -echo	#													with user input hidden
    read RTPWD
    stty echo
    echo "[client]" >> ~/.my.cnf #											and record it
    echo "user=root" >> ~/.my.cnf
    echo "password=$RTPWD" >> ~/.my.cnf
  else	#														if MySQL credentials are recorded
    RTSTR=`grep password ~/.my.cnf` #											get password string from file
    RTPWD=${RTSTR:9} #													and get password from it
fi

if [ ! -z "$(pgrep mysqld)" ] # 											if MySQL is running (if not - the queries below are meaningless and will result only in error messages)
  then
    if [ -z "$RTPWD" ] # 												if root password is NULL, we will run the queries as default root (no credentials specified)
      then
	UEX=`mysql -e "SELECT user FROM mysql.user WHERE user = 'zbxmon';"` # 						Check if user exists
	if [ -z "$UEX" ]  #												if not
	  then
	    ZBXPWD=`openssl rand -base64 40 | sed "s/+//g" | sed "s/\///g" | sed "s/=//g"` # 				create password 
#    echo $ZBXPWD >> ~/zbxpwd
	    mysql -e "CREATE USER 'zbxmon'@'localhost' IDENTIFIED BY '$ZBXPWD';"  # 					Create user with above password
	    echo "MySQL user zbxmon created with password $ZBXPWD"  # 							Report to console
	  else  # 													if user exists
	    echo "MySQL user zbxmon already exists" #									report to console
	fi
      else #														if root password is not NULL,run the queries below with root credentials specified  
	UEX=`mysql -uroot -p$RTPWD -e "SELECT user FROM mysql.user WHERE user = 'zbxmon';"`
#															if zbxmon does not exist 
	if [ -z "$UEX" ]
	  then	#													create password
	    ZBXPWD=`openssl rand -base64 40 | sed "s/+//g" | sed "s/\///g" | sed "s/=//g"` 
#    echo $ZBXPWD >> ~/zbxpwd
	    mysql -uroot -p$RTPWD -e "CREATE USER 'zbxmon'@'localhost' IDENTIFIED BY '$ZBXPWD';" #			create user with password above
	    echo "MySQL user zbxmon created with password $ZBXPWD"  #							report to console
	  else	#													if user exists
	    echo "MySQL user zbxmon already exists" #									report to console
      fi
    fi
fi
#															Check if Zabbix config contains a MySQL line, add if necessary
if grep -Fq "UserParameter=mysql[*]" /etc/zabbix_agentd.conf > /dev/null
  then
    echo "Config already contains MySQL string"
  else
    if [ $MYSQLEX=1 -a -z "$UEX" ]
      then
	sed -i '$a\#MySQL' /etc/zabbix_agentd.conf
	sed -i '$a\UserParameter=mysql[*],/etc/zabbix/plugins/mysql-stats.sh "none" $1 "zbxmon" "'$ZBXPWD'"' /etc/zabbix_agentd.conf
	echo "String addded"
      else
	echo "Config left intact."
    fi
fi
#set +x