#!/bin/bash
if [[ "$1" == "established" ]]; then
established=`ss -s|head -n 2|tail -n 1|awk '{print $4}'|sed 's/,//g'`
echo $established
fi

if [[ "$1" == "time_wait" ]]; then
time_wait=`ss -s|head -n 2|tail -n 1|awk '{print $12}'|sed 's/\//\n/g'|head -n 1`
echo $time_wait
fi
