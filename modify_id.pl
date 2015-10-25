#!/usr/bin/env perl

# modify_id
# User can modify information and attributes
# The script will place the data into a file
# and open it with vim. The user can edit the 
# values and they will be pushed to the database 
# TODO add tags to the modifiable set
# TODO improve formatting

use strict;
use DBI;
use config_t808;

my $id_to_modify = shift;

my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=info_db.db", 
    "",
    "",
    { RaiseError => 1}
) or die $DBI::errstr;

# Retrieve the row
my $sth = $dbh->prepare("SELECT title,info FROM tbl_info WHERE id=$id_to_modify");
$sth->execute();

my $row = $sth->fetchrow_arrayref();

$sth->finish();

my $update_title;
my $update_info;

if ($row) {

   my $title = $$row[0];
   my $info = $$row[1];

   # Transform the info
   my $transformed_info = $info;
   $transformed_info =~ s/$config_t808::content_sep/\n/g;

   # Update title
   my $update_title;
   print "Title:\n\t$title\n";
   print "Update title [y/N]?\n";
   my $update_val = <STDIN>;
   if ($update_val =~ /^[yY]/) {
      $update_title = 1; 
   }
   # Update info
   my $update_info;
   print "Info:\n\t$transformed_info\n";
   print "Update info [y/N]?\n";
   my $update_val = <STDIN>;
   if ($update_val =~ /^[yY]/) {
       $update_info = 1;
   } else {
      if (! $update_title) {
	 print "You did not choose to update the record.\n";
         exit;
      }
   }

   # Create the file
   use File::Temp qw(tempfile);
   my ($fh, $filename) = tempfile( );
   
   if ($update_title) {
      print $fh "$title\n";
   }
   if ($update_info) {
      print $fh "$transformed_info";
   }
   close $fh;

   system "vi $filename";

   # Parse the file and update the database
   my $new_title;
   my $new_info;
   open my $in, '<', $filename or die "Sorry, I couldn't read $filename.\n";
   if ($update_title) {
      $new_title = <$in>;
      chomp($new_title);
   }

   if ($update_info) {
      $/ = undef;
      $new_info = <$in>;
      chomp($new_info);
   }

   close $in;

   unlink $filename;
   # Update the database
   if ($update_title && $title ne $new_title) {
      $dbh->do("UPDATE tbl_info SET title = '$new_title' WHERE id = $id_to_modify");
      print "Updated title:\n\t$new_title\n\n";
   }

   if ($update_info && $transformed_info ne $new_info) {
      # Transform the info
      my $transform_new_info = $new_info;
      $new_info =~ s/\n/$config_t808::content_sep/g;
      $dbh->do("UPDATE tbl_info SET info = '$new_info' WHERE id = $id_to_modify");
      print "Updated info:\n\t$transform_new_info\n\n";
   }
}

$dbh->disconnect();

