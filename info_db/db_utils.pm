package db_utils;

# subroutine to escape single quotes in input
sub escape_db_input() {
   my $input = shift;
   
   # single quotes
   $input =~ s/'/''/g;

   return $input;
}

1;
