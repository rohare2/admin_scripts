#!/bin/sh
#
# $Id: lrm_show_host.sh 13 2012-02-08 16:06:31Z rohare $
# $URL: file:///usr/local/svn/admin/scripts/lrm_show_host.sh $

PATH=/dpcs/bin:$PATH
CLUSTER=$1
LIST=`nodeattr -s "cluster=$CLUSTER--mgmt"`

if [ -f lrm.tmp ] ; then
	rm lrm.tmp
fi

for NODE in $LIST; do
	echo "show host $NODE" >> lrm.tmp
done

if [ -f /usr/local/bin/lrmmgr ] ; then
	/usr/local/bin/lrmmgr -i lrm.tmp
else
	echo "Does not appear to be an LCRM managed node"
fi

rm lrm.tmp
