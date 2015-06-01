#!/usr/bin/perl -w
# $Id: mysqldump.pl 16 2012-04-13 14:06:22Z rohare $
# $URL: file:///usr/local/svn/admin/scripts/mysqldump.pl $

use strict;

my $HOSTNAME = 'restless';
my $USERID = 'rohare';
my $PASSWORD = 'Dday+30';
my $DATABASE_NAME = 'cmdb';

my ($Second,$Minute,$Hour,$Day,$Month,$Year,$WeekDay,$DayOfYear,$IsDST) = localtime(time) ; 

$Year += 1900 ; $Month += 1;

my $dt = sprintf("%04d%02d%02d", $Year, $Month, $Day, ) ;

exec "/usr/bin/mysqldump --opt -h$HOSTNAME -u$USERID -p$PASSWORD -A |gzip > /home/rohare/backups/mysql.dump.$dt.gz";

