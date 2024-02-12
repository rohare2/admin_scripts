#!/usr/bin/perl
# my-suricata-update.pl
#
# wrapper around suricata-update that gets the latest rules and
# then applies my customizations

use strict;
use warnings;
use v5.10;

my $Dir = "/var/lib/suricata/rules";
my $ruleFile = "suricata.rules";
my $chgdFile = "suricata.rules.chgd";

# array of sids for rules that need to be changed
my @sids = (
	"2100498"
);

# get updated rules
`suricata-update`;

open( my $fh, '<:encoding(UTF-8)', "$Dir/$ruleFile")
	or die "Could not open file '$Dir/$ruleFile' $!";

open( my $fh2, '>:encoding(UTF-8)', "$Dir/$chgdFile")
	or die "Could not open file '$Dir/$chgdFile' $!";

while (my $row = <$fh>) {
	my $modrow = $row;
	$modrow =~ s/[\"\']//g;
	if ($modrow =~ /sid:\d+;/) {
		my $sid = `echo '$modrow' | sed 's/^.*sid://' | sed 's/;.*//g'`;
		chomp $sid;
		$sid =~ s/[\n\r]//g;
		if ( $sid ~~ @sids ) {
			print "sid $sid set to drop\n";
			$row =~ s/^alert/drop/;
			print $fh2 "$row";
		} else {
			print $fh2 "$row";
		}
	}
}

close $fh;
close $fh2;
rename "$Dir/$chgdFile", "$Dir/$ruleFile";

`systemctl reload-or-restart suricata`;
