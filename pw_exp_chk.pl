#!/usr/bin/perl -w

use strict;

my $today = sprintf("%d", (time/60/60/24));
my $root_entry;
my @passwdExp;
my $Target = 'dist_test';

my $Query = 'grep "^root" /etc/shadow';

open (LIST, "pssh -g \'$Target\' -c \'$Query\' |") or
	die "Could not run Query: $!";

while (<LIST>) {
	my $entry = $_;
	chomp $entry;

	if ($entry =~ /^root:/) {
		$root_entry = $entry;
		my ($nam,$pwd,$lstchg,$min,$max,$warn,$inact,$expire)
			= split (':', $root_entry);

		if ($max !~ /^$/) {
			my $daysLeft =  $lstchg + $max - $today;
			print "Days left: $daysLeft\n";
			$daysLeft >= 14 ||
			printf("Root password expires in %d days\n",
				$daysLeft);
		}
	}
}
