#!/usr/bin/perl -w
# blocker.pl
#
my $LOGS = `ls /var/log/secure*`;
my @LOGS = split('\n', $LOGS);
my %ipH;
foreach my $file (@LOGS) {
	open(my $fh, $file)
		or die;
	while (my $line = <$fh>) {
		chomp $line;
		if ($line =~ /sshd.*refused connect from/) {
			my @words = split(' ', $line);
			my $ip = $words[9];
			$ip =~ s/\(//;
			$ip =~ s/\)//;
			$ipH{$ip}++;
		}
	}
}

sub top() {
	foreach my $ip (sort { $ipH{$a} <=> $ipH{$b} } keys %ipH) {
		printf "%-16s %4d\n", $ip, $ipH{$ip};
	}
}

sub location() {
	foreach my $ip (sort keys %ipH) {
		if ($ip =~ /^$ARGV[0]/) {
			printf "%-16s %4d\n", $ip, $ipH{$ip};
		}
	}
}

sub ipsort() {
	foreach my $ip (sort keys %ipH) {
		printf "%-16s %4d\n", $ip, $ipH{$ip};
	}
}

if ( $#ARGV == 0 ) {
	if ($ARGV[0] eq 'top') {
		&top;
	} elsif ($ARGV[0] eq 'sort') {
		&ipsort;
	} else {
		&location;
	}
} else {
	print "no arguments?\n";
}
