#!/usr/bin/bash
dec=$1
ip=`echo $dec |awk -F '.' '{printf "%d\n", ($1 * 2^24) + ($2 * 2^16) + ($3 * 2^8) + $4}'`
echo "$ip"
