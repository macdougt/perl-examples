#!/usr/bin/env perl

use strict;
use warnings;

# Catch interrupt
my $dbh;

$SIG{INT} = sub { 
  # Check if the database is up and close it
  if ($dbh) {
    $dbh->disconnect();
    print "Closing database\n";
  }
  die "Caught a sigint $!"
};



use File::ChangeNotify;
use File::Copy;
use XML::Simple;

$| = 1;

# Test
#my $file = '/tmp/yoyo';
#&get_copy_list($file);

my $dir = "/Users/kimberleyarnold/Library/Preferences";
my $plist_file = $dir."/com.generalarcade.flycut.plist";
my $converter_cmd = "plutil -convert xml1";

use File::Temp qw/ tempfile /;

my $watcher = File::ChangeNotify->instantiate_watcher(
  directories => [ '/Users/kimberleyarnold/Library/Preferences/' ],
  filter      => qr/flycut\.plist$/,
);


# Set up the db and connection
use DBI;
my $db_filename = $ENV{"HOME"} ."/clips.db";
# Add info to the database
$dbh = DBI->connect(
    "dbi:SQLite:dbname=$db_filename",
    "",
    "",
    { RaiseError => 1}
) or die $DBI::errstr;

my $max_ts = $dbh->selectrow_array('SELECT max(timestamp) FROM tbl_clips');

if (! $max_ts) {
  $max_ts = 0;
}

print "Last clip time: $max_ts\n";

while ( my @events = $watcher->wait_for_events ) {
  my ($fh, $filename) = tempfile( DIR => '/tmp' );
  print "Use $filename\n";

  # Process on event
  #foreach my $event (@events) {
    #print $event->path()." ".$event->type()."\n";
    # Copy the file to /tmp, convert it and parse it
   copy($plist_file, $filename) or die "Copy failed: $!";
   system("$converter_cmd $filename");
   &get_copy_list($filename, $dbh, $max_ts);
  #}
  # Remove temp file
  unlink $filename;
  print "Removing $filename\n";
}

$dbh->disconnect();


sub get_copy_list {
  my $filename = shift;
  my $dbh = shift;
  my $max_ts = shift;

  my $xml = new XML::Simple;
  my $data = $xml->XMLin($filename);
  my $dict1 = $$data{"dict"};
  my $store = $$dict1{"dict"};
  my $store_dict = $$store[1];
  my $copies_list = $$store_dict{"array"};

  foreach my $rh_item (@$copies_list) {
    my $ra_copy_items = $$rh_item{"dict"};
    foreach my $rh_copy_item (@$ra_copy_items) {
      my $ra_copy_item = $$rh_copy_item{"string"};
      my $timestamp_item = $$rh_copy_item{"integer"};
      my $timestamp = $$timestamp_item[1]; 

      if ($timestamp > $max_ts) {
        # Indices
        # 0 App URL, 1 App name, 2 Contents, 3 Type
        my $application = $$ra_copy_item[1];
        my $contents = $$ra_copy_item[2];
        my $type = $$ra_copy_item[3];
        #print "$$ra_copy_item[2]\n";

        # Add to db, check the timestamp, only add if later than max timestamp in dba
        my @values = ($timestamp, $application, $contents, $type);
        print "($timestamp, $application, $contents, $type)\n";
        my $sth = $dbh->do('INSERT INTO tbl_clips (timestamp, application,contents,type) VALUES (?,?,?,?)',undef, @values);
	# Set the global max to the latest timestamp
        if ($timestamp > $max_ts) {
          $max_ts = $timestamp;
        }
      }
    }
  }
}





