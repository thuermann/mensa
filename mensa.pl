#!/usr/local/bin/perl
#
# $Log: mensa.pl,v $
# Revision 1.4  1994/07/06 21:02:59  urs
# Some code cleanup
#
# Revision 1.3  1994/07/06 21:02:30  urs
# Make library file name configurable through variable
#
# Revision 1.2  1994/07/06 21:02:10  urs
# Use localtime instead of gmtime
#
# Revision 1.1  1994/06/30 17:27:15  urs
# Add script to print the menu of the day for the TU-BS mensa
#
#


# These values should be taken from /usr/local/lib/mensa
$nweeks = 6;
$sync   = 25;

$db = '/usr/local/lib/mensa';

@names = ('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag',
	'Sonnabend', 'Sonntag');

$warp = shift if (@ARGV);
$warp *= 86400;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
	localtime(time + $warp);
# print "$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst\n";

$wday = int (($wday + 6) % 7);	# make monday = 0, tuesday = 1, ...

$day = int((time + $warp) / 86400) - $sync;
$week = int($day / 7) % $nweeks + 1;

open(LIB, $db);

while ($_ = <LIB>, !/^\*/) {
	if (/^$C/) {}
}

print "$week. Woche $names[$wday]\n";

if ($wday == 6) {
	@suggestions = (
		"Heute vielleicht zum Tan Dir?\n",
		"Wann warst Du das letzte mal im gambit?\n",
		"Lad' jemand zum Kochen bei Dir ein!\n",
		"Eat the rich.\n"
	);
	srand;
	print $suggestions[rand $#suggestions + 1];
	exit;
}

# skip to the appropriate day ...

while ($week > 1) {
	$_ = <LIB>;
	$week-- if (/^\*/);
}

while ($wday > 0) {
	$_ = <LIB>;
	$wday-- if (/^#/);
}

# ... and print the menu

while ($_ = <LIB>, !/^(#|\*)/) {
	if (/^\\/) {
		print "Abendmensa:\n";
	} else {
		print;
	}
}
