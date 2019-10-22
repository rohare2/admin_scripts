#!/usr/bin/perl -w
# access_request.pl
use strict;
use DBI;

# MySQL database connection
my $dbhost = "master.ohares.us";
my $dsn = "DBI:mysql:it_ops;host=$dbhost";
my $username = "autoban";
my $password = 'Fluticasone';

# # connect to MySQL database
my %attr = ( PrintError=>0,  # turn off error reporting via warn()
             RaiseError=>1);   # turn on error reporting via die()

my $dbh = DBI->connect($dsn,$username,$password, \%attr);

my $subject;
my $dt = `date '+%Y-%m-%d %H:%M:%S'`;
chomp $dt;
print "$dt\n";

while (<>) {
	my $line = $_;
	my $quad;
	chomp $line;
	if ( $line =~ /^Subject:\s+Request\s+#\d{10}\./ ) {
		$subject = $line;

		my ($header, $integer) = ($subject =~ /(.*#)(.*)/);
		$quad = join '.', unpack 'C4', pack 'N', $integer;;
		print "$quad\n";
	}
}

$dbh->disconnect();
exit 0;
