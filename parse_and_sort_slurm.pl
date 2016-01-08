#!/usr/bin/env perl

# Expected input is produced by calling squeue in the following way:
# 
#   squeue --clusters=serial --format="%i %P %j %u %T %M %l %D %R %Q %p"

use strict;
use warnings;

# read the complete input from the stdin
my @dat = <>;

# split the input at each tab
@dat=map {[split /[\t ]+/, $_] } @dat;

# zero-based Fields #5 and #6 contain times, convert it to seconds to
# make them comparable

@dat = sort {
    $b->[4] cmp $a->[4] ||
	$b->[10] <=> $a->[10]
} @dat; 

foreach (@dat) { 
    print join("\t", @{$_}); 
}

sub timestring_to_sec
{
    my ($in) = @_;

    $in =~ s/^\s+|\s+$//g;

    # valid formats are:
    # 0:00 (min:sec)
    # 00:00:00 (hours:min:sec)
    # 0-00:00:00 (days-hours:min:sec)

    my ($days, $hours, $min, $sec) = (0, 0, 0, 0);

    if ($in =~ /^(\d+):(\d+)$/)
    {
	$min = $1;
	$sec = $2;
    } elsif ($in =~ /^(\d+):(\d+):(\d+)$/)
    {
	$hours = $1;
	$min = $2;
	$sec = $3;
    } elsif ($in =~ /^(\d+)-(\d+):(\d+):(\d+)$/)
    {
	$days = $1;
	$hours = $2;
	$min = $3;
	$sec = $4;
    } else {
	die "Wrong time format found: '$in'\n";
    }

    return (($days*24+$hours)*60+$min)*60+$sec;
}
