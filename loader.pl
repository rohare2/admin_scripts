#! /bin/perl -w
# $Id: loader.pl 13 2012-02-08 16:06:31Z rohare $
# $URL: file:///usr/local/svn/admin/scripts/loader.pl $
# Used to load alias records
use strict;

my $finished;
my $entry;

open (FILE, '< sudoers');

while (<FILE>){
	my $line = $_;
	chomp $line;

	$line =~ '^$' && next;
	$line =~ '^#' && next;

	if ($line =~ /\\/) {
		$finished = 0;
	} else {
		$finished = 1;
	}

	if ($line =~ /=/) {
		$entry = $line;
	} else {
		$entry = $entry . $line;
	}

	if ($finished) {
		$entry =~ s/\\//g;
		$entry =~ s/\s+/ /g;
		$entry =~ s/, /,/g;
		
		if ($entry =~ /Host_Alias/) {
			my $table = 'host_alias';
			$entry =~ s/Host_Alias //;
			$entry =~ s/\s?=\s?/ /;
			my ($alias, $list) = split (/ /,$entry);
			my @list = split(/,/,$list);
			foreach my $host (@list) {
				&InsertAlias($table,$alias,$host);
			}
			next;
		}
		if ($entry =~ /User_Alias/) {
			my $table = 'user_alias';
			$entry =~ s/User_Alias //;
			$entry =~ s/\s?=\s?/ /;
			my ($alias, $list) = split (/ /,$entry);
			my @list = split(/,/,$list);
			foreach my $user (@list) {
				&InsertAlias($table,$alias,$user);
			}
			next;
		}
		if ($entry =~ /Cmnd_Alias/) {
			my $table = 'cmnd_alias';
			$entry =~ s/Cmnd_Alias //;
			$entry =~ s/\s?=\s?/ /;
			my ($alias, $cmnds) = split (/ /,$entry);
			&InsertAlias($table,$alias,$cmnds);
			next;
		}
	}
}

# Insert alias record
sub InsertAlias() {
	my $table = shift @_;
	my $alias = shift @_;
	my $value = shift @_;

	print "$table $alias  $value\n";
	#`mysql nifit -e "insert into $table values('$alias','$value)"`;
}
