#$Id: get_dist.sh 13 2012-02-08 16:06:31Z rohare $
#$URL: file:///usr/local/svn/admin/scripts/get_dist.sh $
#

if [ -d /var/dist ] ; then
	rm -fR /var/dist/*
fi

# Populate /var/dist
/usr/bin/svn export --force file:///usr/local/svn/admin/trunk/dist/ /var/dist
if [ -f /var/dist/etc/shadow ] ; then
	chmod 600 /var/dist/etc/shadow
fi

if [ -f /var/dist/etc/sudoers ] ; then
	chmod 600 /var/dist/etc/sudoers
fi

# Populate /usr/admin/scripts
/usr/bin/svn export --force file:///usr/local/svn/admin/trunk/scripts/ \
	 /usr/admin/scripts/
chown root:root /usr/admin/scripts/*
chmod 554 /usr/admin/scripts/*
