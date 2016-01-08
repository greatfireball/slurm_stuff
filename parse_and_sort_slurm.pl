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

@dat = sort sort_squeue @dat; 

foreach (@dat) { 
    print join("\t", @{$_}); 
}

sub sort_squeue
{
    my $ret = 0;
    # compare for status (running < pending)
    $ret = $b->[4] cmp $a->[4];

    # if we have a value other than 0 we are allowed to return
    if ($ret)
    {
	return $ret;
    }

    # check if they are running or not? One check is suffienct
    if ($b->[4] =~ /running/i)
    {
	# yes... So calculate the rest of the runtime
	my $rest_time_b = timestring_to_sec($b->[6])-timestring_to_sec($b->[5]);
	my $rest_time_a = timestring_to_sec($a->[6])-timestring_to_sec($a->[5]);

	$ret = $rest_time_b <=> $rest_time_a;

	# if we have a value other than 0 we are allowed to return
	if ($ret)
	{
	    return $ret;
	}

    } else {

	# no... Just sort by priority
	$ret = $b->[10] <=> $a->[10];

	# if we have a value other than 0 we are allowed to return
	if ($ret)
	{
	    return $ret;
	}

    }

    # ultimately sort by process number
    return $a->[0] <=> $b->[0]; 
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
