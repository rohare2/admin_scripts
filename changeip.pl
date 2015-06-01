#!/usr/bin/perl -w
#
# $Id: changeip.pl 13 2012-02-08 16:06:31Z rohare $
# $URL: file:///usr/local/svn/admin/scripts/changeip.pl $

use strict;
use Net::Telnet ();

$ENV{PATH} = "/bin:/usr/bin";

# DSL Modem values
my $ModemIP="192.168.0.1";
my $username = "DVCAL_rich";
my $passwd = "Corvette_Z06";
my $InternetIP;

# ChangeIP values
my $DNSSERVER='www.changeip.com:443';
my $TMP="/var/tmp/rohare";
my $cuid = 'rohare';
my $cpwd = '825Work';
my $dname = '55kdc.net';

my ($line, @lines);
my $successstr = 'Successful Update!';

#
## Get domain IP address from DSL Modem
#
my $t = new Net::Telnet->new(Timeout => 10);

$t->open("192.168.0.1");
$t->login($username, $passwd);

@lines = $t->cmd("/sbin/ifconfig | grep 'P-t-P'");

foreach my $line (@lines){
	$line =~ /^#/ && next;
	$line =~ s/^\s+//;
	$line =~ s/\s+/ /;
	my @entry = split(/\s+/, $line);

	$InternetIP = $entry[1];
	$InternetIP =~ s/addr://;
}


#
## Get domain IP from DNS server
#
my @DNS = `host 55kdc.net ns1.changeip.com`;
my $DNS_IP = "$DNS[5]";
$DNS_IP =~ s/55kdc.net has address //;
$DNS_IP =~ s/\n//;


#
## Compare Router and DNS address
#
if ( $InternetIP eq $DNS_IP ) {
	exit;
} else {
	print "Internet IP:    $InternetIP\n";
	print "DNS IP:\t\t$DNS_IP\n";
	print "Changing DNS entry\n";
	my $getstring = "GET /update.asp?u=$cuid&p=$cpwd&cmd=update&hostname=\*1&ip=$InternetIP";
	my $cmd = qq~echo "$getstring" | openssl s_client -quiet -connect $DNSSERVER 2>&1~;

	my @output = `$cmd`;
	print "@output\n";

	# Send email notification
	`echo "Change IP to: $InternetIP" | mail -s \"IP Change\" rohare`;
}


