#!/usr/bin/env perl

use Net::GitHub::V3;
use Dumpvalue;
use Term::ANSIColor qw(colored);
use Getopt::Long;
use Pod::Usage;



GetOptions(
  'repo=s' => \my $repo_query,
  'code=s' => \my $code_query,
  'help|?!' => \my $help, 
  'man!' => \my $man,
) or die "Invalid options passed to $0\n";


pod2usage(-verbose => 1) && exit if defined $help;
pod2usage(-verbose => 2) && exit if defined $man;

if (! ($repo_query || $code_query)) {
	pod2usage(-verbose => 1);
	exit 1;
}

my $dumper = new Dumpvalue;

# unauthenticated
my $gh = Net::GitHub::V3->new;
my $search = $gh->search;

my %data = $search->repositories({
        q => $repo_query,
        sort  => 'stars',
        order => 'desc',
    });

#$dumper->dumpValue(\$data{items});

my $ra_items = $data{items};
my $total_count = $data{total_count};

print "Found $total_count repositories\n";

print "Repositories:\n";

foreach my $rh_item (@$ra_items) {
  sleep 5; # slow things
  my $repo_full_name = $$rh_item{full_name};
  print colored($repo_full_name, 'blue');
  print "\n\tStars:\t$$rh_item{stargazers_count}\n";

  # Perform repositories refined search
  my %repo_data = $search->code({ q => "repo:$repo_full_name $code_query"});
  $dumper->dumpValue(\$repo_data{items});

}

=head1 NAME

 github_search.pl

=head1 SYNOPSIS

 github_search.pl --repo "stars:>100000" --code "filename:.travis.yml"

=head1 DESCRIPTION

  Perform search on all repositories and then apply code query to code in those repositories (i.e. refined search)

=head1 ARGUMENTS

 --help      print Options and Arguments
 --man       print complete man page
 --repo      process repositories matching the repo query
 --code      process code matching the code query

=head1 AUTHOR

yoman

=cut
