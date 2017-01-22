#!/usr/bin/perl -w

use strict;
use warnings;
use Parse::RecDescent;

# Create and compile the source file
my $parser = Parse::RecDescent->new(q(
  startrule : day  month /\d+/
{ print "Day: $item{day} Month: $item{month} Date: $item[3]\n"; }
  day : "Sat" | "Sun" | "Mon" | "Tue" | "Wed" | "Thu" | "Fri"

  month : "Jan" | "Feb" | "Mar" | "Apr" | "May" | "Jun" |
          "Jul" | "Aug" | "Sep" | "Oct" | "Nov" | "Dec"
));

# Test it on sample data
print "Valid date\n" if $parser->startrule("Thu Mar 31");
print "Invalid date\n" unless $parser->startrule("Jun 31 2000");


