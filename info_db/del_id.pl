#!/usr/bin/env perl

# Delete the connections to the tag with specified id
# Delete the information with the specified id

use strict;
use DBI;
use config_t808;


my $id_to_delete= shift;


my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=$config_t808::db_filename", 
    "",
    "",
    { RaiseError => 1}
) or die $DBI::errstr;

# Delete references to info in the junction table
$dbh->do("DELETE FROM tbl_info_tag_ref WHERE info_id = $id_to_delete");

# Delete info from info table 
$dbh->do("DELETE FROM tbl_info WHERE id = $id_to_delete");

$dbh->disconnect();

