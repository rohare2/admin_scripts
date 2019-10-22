#!/usr/bin/bash
ip=$1
decip=`echo $ip |awk -F '.' '{printf "%d\n", ($1 * 2^24) + ($2 * 2^16) + ($3 * 2^8) + $4}'`
echo "$decip"
