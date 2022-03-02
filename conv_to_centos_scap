#!/bin/env bash
# mk_centos_scap_content.sh
#
# This script takes rhel scap content and converts it to centos content

DIR="/usr/share/xml/scap/ssg/content"

PWD=`pwd`
cd $DIR
for file in `ls ssg-rhel7-*`;
do
	newfile=`echo $file | sed -e 's/rhel7/centos7/'`
	cp $file $newfile
	sed -i -e 's/redhat\:enterprise_linux/centos\:centos/g' $newfile
done

cd $PWD
