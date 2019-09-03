#!/bin/perl -w
#
# autoban_ssh.pl

use strict;
use DBI;

# MySQL database connection
my $host = "master.ohares.us";
my $dsn = "DBI:mysql:it_ops;host=$host";
my $username = "autoban";
my $password = 'Fluticasone';

# connect to MySQL database
my %attr = ( PrintError=>0,  # turn off error reporting via warn()
             RaiseError=>1);   # turn on error reporting via die()

my $dbh = DBI->connect($dsn,$username,$password, \%attr);

my %mon2num = qw(
	jan 01  feb 02  mar 03  apr 04  may 05  jun 06
	jul 07  aug 08  sep 09  oct 10 nov 11 dec 12
);

# load blacklist
my $list = `firewall-cmd --permanent --info-ipset=blacklist`;
chomp $list;

# read through /var/log/secure file and process results
my $file = "/var/log/secure";
open ( FH, "<$file") || die "Can't open $file: $!\n";

while (<FH>) {
	my $line = $_;
	my ($user,$ipv4);
	if ( $line =~ 'sshd\[\d+\\].*Failed password for ' ) {
		my @line = split(' ', $line);
		my $year = `date '+%Y'`;
		chomp $year;
		my $month = $mon2num{lc substr($line[0], 0, 3) };
		my $day = sprintf("%02d", $line[1]);
		my $found = 0;

		my $dt = "$year-$month-$day $line[2]";

		if ( $line =~ 'invalid user' ) {
			$user = $line[10];
			$ipv4 = $line[12];
		} else {
			$user = $line[8];
			$ipv4 = $line[10];
		}

		# exclude ohares.us domain address
		$ipv4 eq '67.174.210.180' && next;
		# exclude master
		$ipv4 eq '192.168.1.20' && next;
		$ipv4 eq '127.0.0.1' && next;

		# accept group remote_users
		my $remote_list = `getent group remote_users`;
		chomp $remote_list;
		$remote_list =~ s/^.*://;
		if ( $remote_list =~ /$user(\@ohares\.us)?/ ) {
			next;
		}

		# check for an existing database entry
		$found = checkDatabase($dt,$user,$ipv4);

		# If there is no existing database entry create one
		not($found) && updateDatabase($dt,$user,$ipv4,'ssh');

		# check for an existing blacklist entry
		$found = 0;
		$found = checkBlacklist($ipv4); 
		
		# if there is no exisiting blacklist entry create one
		not($found) && updateBlacklist($ipv4); 
	}
}
$dbh->disconnect();

sub checkDatabase {
	my $dt = shift @_;
	my $user = shift @_;
	my $ipv4 = shift @_;
	my $found = 0;
	my $sth = $dbh->prepare("SELECT date,user,INET_NTOA(ipv4) AS ip
		FROM autoban");
	$sth->execute();
	while (my $ref = $sth->fetchrow_hashref()) {
		if ( $ref->{'date'} eq $dt &&
		     $ref->{'user'} eq $user &&
		     $ref->{'ip'} eq $ipv4 ) {
			$found = 1;
		}
	}
	$sth->finish();
	return $found;
}

sub updateDatabase {
	my $dt = shift @_;
	my $user = shift @_;
	my $ipv4 = shift @_;
	my $service = shift @_;
	$host =~ s/\..*//;

	$dbh->do("INSERT INTO autoban SET 
		date = '$dt',
		user = '$user',
		ipv4 = INET_ATON('$ipv4'),
		service = '$service',
		host = '$host'");
	return;
}

sub checkBlacklist {
	my $ipv4 = shift @_;
	if ( $list =~ $ipv4 ) {
		return 1;
	} else {
		return 0;
	}
}

sub updateBlacklist {
	my $ipv4 = shift @_;
	`firewall-cmd --permanent --ipset=blacklist --add-entry="$ipv4"`;
	`firewall-cmd --ipset=blacklist --add-entry="$ipv4"`;
	$list = $list . " $ipv4";
	return;
}
