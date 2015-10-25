#!/usr/bin/env perl

# Print the information associated with the specified tag

use strict;
use DBI;

use config_t808;

my $tag = shift;
my $containing = shift;

# Formatting modes
my $GREEN_BOLD="\e[1;32m";
my $NORMAL="\e[m";


my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=$config_t808::db_filename", 
    "",
    "",
    { RaiseError => 1}
) or die $DBI::errstr;


my $sth = $dbh->prepare("SELECT tbl_info.* FROM tbl_info,tbl_info_tag_ref,tbl_tag WHERE tbl_tag.tag = '$tag' AND tbl_tag.id = tbl_info_tag_ref.tag_id AND tbl_info_tag_ref.info_id=tbl_info.id");
$sth->execute();

my $row;
my $row_number = 1;
while ($row = $sth->fetchrow_arrayref()) {
   if (! $containing || $$row[0] =~ /$containing/ || $$row[2] =~ /$containing/) { 
      print "\n$row_number ${GREEN_BOLD}\[$$row[1]] ${NORMAL}(id $$row[0] - $$row[4]) $$row[3]\n";
      $row_number++;
      my $content = $$row[2];
      $content =~ s/$config_t808::content_sep/\n/g;
      print "$content\n";  
      print "-------------------------------------------------------------\n";
   }

}

print "\n";

$sth->finish();
$dbh->disconnect();

