#!/usr/bin/env perl

# Set the standard out to utf-8 encoding
binmode STDOUT, ":utf8";

# Set up temporary file, could use perl to create temp file
my $file = "yoyo.tmp";
my $sep = "\x{2063}";
# Array to test
my @test_array = ("a","b\nwith space and ' &  ^ other characters 	 tab <- end","c","d");

# Write to a file with the utf8 set
open (FILE, "> $file") || die "Sorry, I couldn't write $file.\\n";
binmode(FILE, ":utf8");

print FILE join($sep, @test_array);
close FILE;

# Read file as line; slurp mode
undef $/;

open (INFILE, "< $file") || die "Sorry, I couldn't write $file.\\n";
binmode(INFILE, ":utf8");

my $content = <INFILE>;

print "Just printing content:\n$content\n";

my @parsed_content = split(/ /, $content);
print "parsed content by space:\n@parsed_content\n";

use Dumpvalue;
my $dumper = new Dumpvalue;
$dumper->dumpValue(\@parsed_content);

my @parsed_content2 = split(/$sep/, $content);
print "\n\n2 parsed content by special character @parsed_content2\n";

$dumper->dumpValue(\@parsed_content2);

close INFILE;

# Clean up file
unlink $file;

