#!/bin/sh
#$Id: get_edi_web_updates.sh 13 2012-02-08 16:06:31Z rohare $
#$URL: file:///usr/local/svn/admin/scripts/get_edi_web_updates.sh $

www="/var/www/html"
old="${www}/edi"
new="${www}/edi_new"

user=`/usr/bin/whoami`
if [ $user == "root" ]; then
	echo "Root is not authorized to run this script"
	exit 1
fi

if ( ! nodeattr edi_http ); then
	echo "This script can only be run from the EDI Web Server"
	exit 1
fi

if [ -x $new ]; then
	rm -fR $new
fi


pushd $www > /dev/null
tar czvf /var/tmp/edi_$$.tgz $old

svn export svn+ssh://lanai1/usr/local/svn/EDI/trunk/www/ $new/
chgrp -R edi $new
chmod -R g+w $new
chmod o+rx $new
chmod -R o+r $new
find $new -type d -exec chmod o+x {} \;


rm -fR $old
mv $new $old
popd > /dev/null
