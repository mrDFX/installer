#!/bin/bash
server='127.0.0.1'
cd /etc/zabbix/plugins
echo "use hhs" > 1.js
echo "db.stats(1024000000)" >> 1.js
echo "exit" >> 1.js
#limit=`df -h /|tail -n 1|awk '{print $2}'|sed 's/T//'`
#let limit=$limit*1000
#let limit=$limit-10
limit=1690

echo "use local" > 2.js
echo "db.stats(1024000000)" >> 2.js
echo "exit" >> 2.js
local=`mongo $server:27017 < 2.js | grep fileSize | awk '{print $3}' | sed 's/,//g'`
localdb=`mongo $server:27017 < 2.js | grep dataSize | awk '{print $3}' | sed 's/,//g'`
localstorage=`mongo $server:27017 < 2.js | grep storageSize | awk '{print $3}' | sed 's/,//g'`

total=`mongo $server:27017 < 1.js | grep fileSize | awk '{print $3}' | sed 's/,//g'`
db=`mongo $server:27017 < 1.js | grep dataSize | awk '{print $3}' | sed 's/,//g'`
dbstorage=`mongo $server:27017 < 1.js | grep storageSize | awk '{print $3}' | sed 's/,//g'`
index=`mongo $server:27017 < 1.js | grep indexSize | awk '{print $3}' | sed 's/,//g'`
if [[ "$1" == 'total' ]]; then
let total=$total+$local
echo $total
fi
if [[ "$1" == 'db' ]]; then
let db=$db+$localdb
echo $db
fi
if [[ "$1" == 'storage' ]]; then
let dbstorage=$dbstorage+$localstorage
echo $dbstorage
fi
if [[ "$1" == 'index' ]]; then
echo $index
fi
if [[ "$1" == 'limit' ]]; then
echo $limit
fi

exit
