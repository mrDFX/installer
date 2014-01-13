#!bin/bash
if [ -z "$(pgrep mysqld)" ]
  then
     echo "MySQL is not running. Checking autoload."
     if [ -f /etc/rc.d/init.d/mysqld ]
	then
	  echo "MySQL is in autoload, but not running"
	  $mysqlex=1
	else 
	  echo "MySQL is not running and not in autoload"
	  $mysqlex=0
    fi
  else
    echo "MySQL is running"
    $mysqlex=1
fi

if grep -Fxq "UserParameter=mysql[*]" /etc/zabbix_agentd.conf > /dev/null
  then
   echo "Config already contains MySQL string"
  else
    if $mysqlex=1
      then
	sed -i '$a\ UserParameter=mysql[*],/etc/zabbix/plugins/mysql-stats.sh "none" $1 $mysql_user_zbx $mysql_passwd_zbx' /etc/zabbix_agentd.conf
	echo "String addded"
    fi
fi