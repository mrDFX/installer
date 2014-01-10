#!/bin/bash
### OPTIONS VERIFICATION
if [[ -z "$1" || -z "$2" ]]; then
 exit 1
fi

##### PARAMETERS #####
RESERVED="$1"
METRIC="$2"
USER="${3:-user}"
PASS="${4:-pass}"
#
MYSQLADMIN="/usr/bin/mysqladmin"
MYSQL="/usr/bin/mysql"
FILECACHE="/tmp/zabbix.mysql.cache"
TTLCACHE="55"
TIMENOW=`date '+%s'`
##### RUN #####
if [ $METRIC = "alive" ]; then
 $MYSQLADMIN -u$USER -p$PASS ping | grep alive | wc -l
 exit 0
fi
if [ $METRIC = "version" ]; then
 $MYSQL -V | sed -e 's/^.*\(ver.*\)$/\1/gI'
 exit 0
fi
if [ -s "$FILECACHE" ]; then
 TIMECACHE=`stat -c"%Z" "$FILECACHE"`
else
 TIMECACHE=0
fi
if [ "$(($TIMENOW - $TIMECACHE))" -gt "$TTLCACHE" ]; then
 echo "" >> $FILECACHE # !!!
 DATACACHE=`$MYSQLADMIN -u$USER -p$PASS extended-status` || exit 1
 echo "$DATACACHE" > $FILECACHE # !!!
fi
#
cat $FILECACHE | grep -iw "$METRIC" | cut -d'|' -f3
#
rm /tmp/zabbix.mysql.cache
exit 0

