#!/usr/local/bin/perl
#
# $Log: mensa.pl,v $
# Revision 1.7  1994/09/22 20:24:27  urs
# Accept dates in the form dd.mm.[cc]yy on the command line
#
# Revision 1.6  1994/07/08 16:59:56  urs
# Check the return code of open
#
# Revision 1.5  1994/07/06 21:11:30  urs
# Handle $C and $S specifications
#
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
# sync should be the date of a first week's Monday.
$nweeks = 6;
@sync   = (1994,2,7);

$db = '/usr/local/lib/mensa';

#days in the year before January, February, ...
@days = (0,31,59,90,120,151,181,212,243,273,304,334);

@names = ('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag',
	'Sonnabend', 'Sonntag');

# The regular expr for dates with three parenthesized sub-expressions
$date = "(\\d+)\\.(\\d+)\\.(\\d+)";

if ($_ = $ARGV[0], /$date/) {
	$year = $3;
	$year += 1900 if ($year < 1900);
	@today = &yday($year,$2,$1);
} else {
	$warp = shift if (@ARGV);
	$warp *= 86400;

	@today = (localtime(time + $warp))[5,7];
	@today[0] += 1900;
}

open(LIB, $db) || die "Can't open $db\n";

while ($_ = <LIB>, !/^\*/) {
	if (/^\$[SC] *$date *- *$date/) {
		# get dates to @date1 and @date2
		@date1 = &yday($3,$2,$1);
		@date2 = &yday($6,$5,$4);

		if (&diff(@date1, @today) >= 0
		    && &diff(@today, @date2) >= 0) {
			print "Mensa geschlossen\n" if (/\$C/);
			print "Sonderwoche\n" if (/\$S/);
			exit;
		}
	}
}

$day  = &diff(&yday(@sync), @today);
($week, $wday) = &divmod($day, 7);
$week = $week % $nweeks + 1;

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

# This assumes that every year which is a multiple of 4 is a leap year.
# So don't use this script after Dec 31, 2100.
# I'm sorry that I won't be able to come up with a better version when
# this becomes neccessary )-:
# However, it isn't known today, if there will be a `Mensa' at the TU or
# the TU at all at that time.

sub diff {
	local($y1, $d1, $y2, $d2) = @_;

	local($d) = (365 - $d1) + ($y2 - $y1 - 1) * 365 + $d2
			+ (int(($y2 - 1) / 4) - int(($y1 + 3) / 4) + 1);

	return $d;
}

sub yday {
	local($y, $m, $d) = @_;

	local($yd) = $days[$m - 1] + $d - 1;
	$yd++ if ($y % 4 == 0 && $m > 2);

	return ($y, $yd);
}

# return (floor(n/d), n%d)
sub divmod {
	local($n, $d) = @_;

	local($q, $r) = (int($n / $d), $n % $d);
	if ($n < 0 && $r != 0) {
		$q--;
	}
	return ($q, $r);
}
