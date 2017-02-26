#!/usr/bin/env perl

use JSON;
use Data::Dumper;
my $sep;
my $command = shift;

my $command_file = $ENV{"HOME"} . "/.interactive/".$command;

if ( -f $command_file ) {
  # Read the file
  $sep = $/;
  undef $/;

  open(FILE, "< $command_file") or die "I cannot open $command_file\n";
    $content = <FILE>;
  close FILE;

  my $content = &replace_in_quotes($content,"\\n");

  # Put the default separator back
  $/ = $sep;

  my $obj_content = decode_json($content);
  print "\n".$$obj_content{"help"}."\n\n";

  my $choice_set = $$obj_content{"choices"};

  my %VARS = ();
  
  foreach my $choice (@$choice_set) {
    while (my ($key, $value) = each %$choice) {
      my @list;

      # Replace state if possible
      while ($value =~ /<(\w+)>/g) {
        my $match = $1;
        if (exists($VARS{$match})) {
	  $value =~ s/<$match>/$VARS{$match}/;
	}
      }
      print "Choose $key:\n";
      open (PIPE, "$value |") || die "Sorry, I couldn't open pipe.\n";
        while (<PIPE>) {
          chomp($_);
          push(@list, $_);
        }
      close PIPE;
      my $chosen_val = &getPick(\@list);
      print "You chose $chosen_val for $key\n";
      $VARS{$key} = $chosen_val;
    }
  }

  # Build and run the command
  my $overall_command = $$obj_content{"command"};
  # Replace state if possible
  while ($overall_command =~ /<(\w+)>/g) {
    my $match = $1;
    if (exists($VARS{$match})) {
      $overall_command =~ s/<$match>/$VARS{$match}/;
    }
  }
  print "Running $overall_command\n"; 
  open (PIPE, "$overall_command |") || die "Sorry, I couldn't open pipe.\n";
    while (<PIPE>) {
      print;
    }
   close PIPE;

}

# Print an interactive choice from a given list
sub getPick {
   my $ra_list = shift;
   if ($#{$ra_list} > 0) {
        print STDERR "List:\n";
        for (my $i=0; $i <= $#{$ra_list}; $i++) {
           print STDERR ($i+1);
           print STDERR ") $$ra_list[$i]\n";
        }
        print STDERR "Make your choice\n";
        my $choice = <STDIN>;
        if ($choice =~ /\d+/) {
           return $$ra_list[$choice-1];
        }
   } elsif ($#{$ra_list} == 0) {
        return $$ra_list[0];
   } else {
        print STDERR "No list\n";
   }
}

sub replace_in_quotes {
   my $target_string = shift;
   my $replacement = shift;
   my $ret_content = "";
   my $quote_state = 0;

   while ( $target_string =~ /(.)/gms) {
      my $cur_char = $1;
      if ($cur_char eq '"') {
         # Toggle the in quote state
         if ($quote_state) {
	    $quote_state = 0;
         } else {
            $quote_state = 1;
         }
         $ret_content .= $cur_char;
      } elsif ($quote_state && $cur_char eq "\n") {
         $ret_content .= $replacement;
      } else {
         $ret_content .= $cur_char;
      }
   }
   return $ret_content;
}


