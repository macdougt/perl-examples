#!/usr/bin/env perl

#
# add_info
# User can add infos to the database
# The user will be prompted for a:
#    - Title (one line)
#    - Content (multiple lines followed by line with . only)
#    - Tags (space delimited list of tags)
#
# The info will automatically be added to the database
# The tags will be added if they do not already exist
# The relationship betwen tags and info
#

use strict;
use DBI;

use config_t808;

my $sep = $/;

# Ask user for a title
print "Title?\n";
my $title = <STDIN>;

# Remove line feed
chomp($title);

# Ask user for the info content
# Support multiline input, user has put a '.' on a line alone
# to signify the end of the input
$/ = "\n.\n";

print "Content?\n";

my $content;

while (<STDIN>) {
    chomp;
    s/\n/$config_t808::content_sep/g;
    $content = $_;
    last;
}

# Ask the user for tags
print "Tags?\n";

# Revert separator to original value
$/ = $sep;

my $tags_input = <STDIN>;

# Parse the tags space delimited
my @tags = split(/\s+/, $tags_input);

# Show the user what he/she connected
print "You have associated @tags with:\n";

my $output_content = $content;
$output_content =~ s/$config_t808::content_sep/\n/g;
print "$output_content\n";

# For metadata keep the user, the database also contains the timestamp that
# the info was added
my $hostname = `hostname -s`;
chomp($hostname);
my $user = getlogin()."@".$hostname;

# Escape the content
$content =~ s/'/''/g;

# Add info to the database
my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=$config_t808::db_filename", 
    "",
    "",
    { RaiseError => 1}
) or die $DBI::errstr;

#print "INSERT INTO tbl_info (title,info,user) VALUES ('$title','$content','$user')";

# Insert title, content and user into the info table
$dbh->do("INSERT INTO tbl_info (title,info,user) VALUES ('$title','$content','$user')");

# Get the insert number
my $last_info_insert_id = $dbh->last_insert_id("","","","");

# Insert tags into the info table if do not yet exist
foreach my $cur_tag (@tags) {
   &insert_info_tag_connections($dbh, $cur_tag, $last_info_insert_id);
}

$dbh->disconnect();

#
# This subroutine will add the tag if necessary
# and the connections to the info (referenced by the info_id)
#
sub insert_info_tag_connections() {
   my $dbh = shift;
   my $tag = shift;
   my $info_id = shift;
   
   my $sth = $dbh->prepare("SELECT tbl_tag.id FROM tbl_tag WHERE tbl_tag.tag = '$tag'");
   $sth->execute();
   my $tag_array = $sth->fetch();
   my $tag_id = $$tag_array[0];

   # Not in the database so add it
   if (! $tag_id) {
      $dbh->do("INSERT INTO tbl_tag (tag) VALUES ('$tag')");
      $tag_id = $dbh->last_insert_id("","","","");
   }

   # Assume the info is new
   #print "INSERT INTO tbl_info_tag_ref (info_id,tag_id) VALUES ($info_id,$tag_id)\n";
   $dbh->do("INSERT INTO tbl_info_tag_ref (info_id,tag_id) VALUES ($info_id,$tag_id)");
}


