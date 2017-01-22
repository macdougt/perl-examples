#!/usr/bin/perl -w

use strict;
use warnings;
use Parse::RecDescent;
use Data::Dumper;

use vars qw(%VARIABLE);

# Enable warnings within the Parse::RecDescent module.

$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.

my $arg = shift || "no";

if ($arg =~ /trace/) {
   $::RD_TRACE  = 1; # Parse::RecDescent trace
}

my $grammar = <<'_EOGRAMMAR_';

  # Terminals (macros that can't expand further)
  #

  all_content: content eofile|content all_content eofile
  content : quoted_content|non_quoted_content

  quoted_content : /"(([^"]*)*(\\["\\])?)*"/
    { $item[1] =~ s/e/o/; $return = $item[1]; print "-$item[1]" 
    } 
  
  non_quoted_content : /[a-z]*/
    { $item[1] =~ s/e/i/; $return = $item[1]; print "*$item[1]" 
    } 

  eofile: /^\Z/

  print_instruction  : /print/i all_content 

  instruction : print_instruction

  startrule: instruction(s /;/)

_EOGRAMMAR_

my @strings = ();
push(@strings, "print test \"testi\"");
push(@strings, "print \"test\" testi");


my $parser = Parse::RecDescent->new($grammar);


# TODO still matching twice, and it applies the rule twice
foreach my $string (@strings) {
   print "$string\n";             
   my $ret_val = $parser->startrule($string);
   print "\n";
}

