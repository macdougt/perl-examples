#!/usr/bin/env perl

# Print all tags

use strict;
use DBI;

use config_t808;

my $id = shift;

my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=$config_t808::db_filename", 
    "",
    "",
    { RaiseError => 1}
) or die $DBI::errstr;


my $sth = $dbh->prepare("SELECT * FROM tbl_tag ORDER BY tag ASC");
$sth->execute();

my $row;
while ($row = $sth->fetchrow_arrayref()) {
   print "$$row[1]\n";
}

print "\n";

$sth->finish();
$dbh->disconnect();

