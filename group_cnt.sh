#!/usr/bin/ksh

cat /etc/passwd | cut -d : -f 1 | while read id ; do
	cnt=`groups $id | awk -F" " '{print NF}'`
	if (( $cnt > 16 )) ; then
		echo "$id: $cnt"
	fi
done

