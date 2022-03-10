#!/bin/env perl

use warnings;
use strict;
use DBI;
use Data::Validate::IP;

# Define default values
my $host = 'www';
my $service = 'http';
my $dt = 'NOW()';
my ($user,$pass) = ("","");

# Verify mysql defaults file exists
-f "$ENV{HOME}/\.my\.cnf" or die "ERROR: $ENV{HOME}/.my.cnf missing\n";

# Get IP argument
my $ip = shift or die "No IP provided\n";
chomp $ip;

# Validate IP agrument
my $validator=Data::Validate::IP->new;
if($validator->is_ipv4($ip))
{
	print "Adding $ip to block list.\n";
}
else
{
	print "Nope, $ip is not a valid IPv4 address.\n";
}

# MySQL database connection
my $dsn = "DBI:mysql:it_ops;mysql_read_default_file=$ENV{HOME}/.my.cnf";
my %attr = ( PrintError=>0,  # turn off error reporting via warn()
             RaiseError=>1);   # turn on error reporting via die()
my $dbh = DBI->connect($dsn,$user,$pass, \%attr);

# run db update routine
updateDatabase($dt,$host,$user,$service,$ip);

$dbh->disconnect();

# Update database
sub updateDatabase {
	my $dt = shift @_;
	my $host = shift @_;
	my $user = shift @_;
	my $service = shift @_;
	my $ip = shift @_;

	my $sth = $dbh->prepare("SELECT date,host,user,service,ip
		FROM autoban
		WHERE date = ?
		AND host = ?
		AND user = ?
		AND service = ?
		AND ip = ?");
	$sth->execute($dt,$host,$user,$service,$ip)
		or die "Couldn't execute statement: " . $sth->errstr;

	if ($sth->rows == 0) {
		$dbh->do("INSERT INTO autoban SET 
			date = $dt,
			host = '$host',
			user = '$user',
			service = '$service',
			ip = '$ip' ");
	}
	$sth->finish();
}
