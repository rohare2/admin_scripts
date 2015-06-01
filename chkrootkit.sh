#! /bin/sh
#$Id: chkrootkit.sh 13 2012-02-08 16:06:31Z rohare $
#$URL: file:///usr/local/svn/admin/scripts/chkrootkit.sh $
#
CHKROOTKIT=/usr/bin/chkrootkit
CURRENT=/tmp/chkrootkit.out
PREVIOUS=/tmp/chkrootkit.last

if [ -f $CURRENT ]; then
	cp -p $CURRENT $PREVIOUS
else
	echo "First run"
fi

${CHKROOTKIT} -q > $CURRENT

if [ -f $PREVIOUS ]; then
	diff $PREVIOUS $CURRENT
fi

chmod 600 $CURRENT
chown root:root $CURRENT

if [ -f $PREVIOUS ]; then
	chmod 600 $PREVIOUS
	chown root:root $PREVIOUS
fi
