#!/usr/bin/env perl

my $total = 100;
my $count = 25;
eval  { $average =  $total / $count };

if ($@) {
  print "Error captured : $@\n";
  print;
} else {
  print "No error, average is: $average\n";
}

$count = 0;

eval  { $average =  $total / $count };

if ($@) {
  print "Error captured : $@\n";
  print "Recover here\n";
} else {
  print "No error, average is: $average\n";
}

print "Later on that night...\n";

