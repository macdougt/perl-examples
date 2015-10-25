#!/usr/bin/env perl

# Print the info associated with the specified id

use strict;
use DBI;

use config_t808;

my $id = shift;

# Formatting modes
my $GREEN_BOLD="\e[1;32m";
my $NORMAL="\e[m";

my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=$config_t808::db_filename", 
    "",
    "",
    { RaiseError => 1}
) or die $DBI::errstr;


my $sth = $dbh->prepare("SELECT * FROM tbl_info WHERE id = $id");
$sth->execute();

my $row;
while ($row = $sth->fetchrow_arrayref()) {
   print "\n$row_number ${GREEN_BOLD}\[$$row[1]] ${NORMAL}(id $$row[0] - $$row[4]) $$row[3]\n";
   my $content = $$row[2];
   $content =~ s/$config_t808::content_sep/\n/g;
   print "$content\n\n";  
}

print "\n";

$sth->finish();
$dbh->disconnect();

