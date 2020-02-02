#! /usr/bin/perl -w
# References:
#    http://www.ipdeny.com/ipblocks/
#    https://www.linode.com/community/questions/11143/top-tip-firewalld-and-ipset-country-blacklist
#
use strict;

my $dir = "/var/tmp/ipdeny";

# download new zone files
zoneUpdate($dir);

opendir my $dh, $dir or die "Could not open '$dir' for reading: $1\n";

# don't add these files to blacklist
my @excludelist = ("local.zone", "us.zone");

# delete existing blacklist
`firewall-cmd --permanent --delete-ipset=blacklist` or die "failed to delete ipset";

# recreate blacklist
`firewall-cmd --permanent --new-ipset=blacklist --type=hash:net --option=family=inet --option=hashsize=4096 --option=maxelem=200000` or die "failed to create ipset";

# build firewall-cmd args
my @args = ("firewall-cmd", "--permanent", "--ipset=blacklist");

my $maxElem = checkOptions();
print "Blacklist limited to $maxElem subnet entries\n";

# read all the zone files
my $sum = 0;
while (my $file = readdir $dh) {
	if ($file =~ '\.zone$') {
		# skip files on the exclusion list
		if ( grep ( /^$file$/, @excludelist ) ) {
			print "skipping $file\n";
			next;
		}

		# keep a running total of subnet entries and don't go over maxElem
		my $ans = `wc -w ${dir}/${file}`;
		my ($cnt,$fn) = split(/ /, $ans);
		$sum = $sum + $cnt;

		if ( $sum >= $maxElem ) {
			print "Warning, the current configuration requires more network\n";
			print "entries than the current max of $maxElem.\n";
			closedir $dh;
			exit;
		}

		# build firewall-cmd arguments 
		push(@args, "--add-entries-from-file=${dir}/${file}");
	}
}
closedir $dh;

# load firewall
system(@args) == 0
	or die "failed to add zone files";
@args = ("firewall-cmd", "--reload");
system(@args) == 0
	or die "failed to reload firewall";

sub checkOptions {
	my ($maxElem,$optionStr,%optionHash);
	my ($key,$val);
	open(FW_SET, "firewall-cmd --permanent --info-ipset=blacklist|");	
	
	while (<FW_SET>) {
		$_ =~ 'options:' && ($optionStr = $_);
	}
	chomp $optionStr;
	$optionStr =~ s/^ +//;
	$optionStr =~ s/options://;
	$optionStr =~ s/^ +//;
	my @optionArray = split(/ /, $optionStr);
	foreach (@optionArray) {
		($key, $val) = split "=";
		$optionHash{$key} = $val;
	}
	$maxElem = $optionHash{'maxelem'};
	return $maxElem;
}

sub zoneUpdate {
	my $dir = shift @_;
	my @args = ("wget", "--directory-prefix=${dir}/", "http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz");
	system(@args) == 0
		or die "failed to download updated zone files";

	@args = ("tar", "-xzf", "${dir}/all-zones.tar.gz", "-C", "${dir}");
	system(@args) == 0
		or die "tar extraction failed";

	@args = ("rm", "-f", "${dir}/all-zones.tar.gz");
	system(@args) == 0
		or die "can't remove all-zones.tar.gz";
}
