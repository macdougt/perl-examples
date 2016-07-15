#!/usr/bin/env perl

=begin EXPLANATION

The code below represents a solver for the puzzle raised in March 2016 on ponder this
(http://www.research.ibm.com/haifa/ponderthis/challenges/March2016.html).

Here are the squarereversed numbers that I found along with their respective squares:
0 -- 0
1 -- 1
5 -- 25
6 -- 36
963 -- 927369
9867 -- 97357689
65766 -- 4325166756
69714 -- 4860041796
6317056 -- 39905196507136
90899553 -- 8262728735599809
169605719 -- 28766099917506961
4270981082 -- 18241279402801890724
96528287587 -- 9317710304478578282569
692153612536 -- 479076623346635216351296
465454256742 -- 216647665119247652454564
182921919071841 -- 33460428476925148170919129281
655785969669834 -- 430055238015804438966969587556
650700037578750084 -- 423410538904986771480057875730007056
125631041500927357539 -- 15783158588607732036935753729005140136521
673774165549097456624 -- 453971626161382585982426654790945561477376
 
The last solution has length 21.
 
My solution uses the fact that perfect squares must end in 0,1,4,5,6 and 9 (rule 1).
 
Assume the square s of a squarereversed number a has positions from 0 to its length-1. I will use indexing a-1 = alength-1 for shorthand.
 
Since a0 = s-1 (rule 2), I am disregarding perfect squares for which s-1 = 0 aside from 0 itself. (assumption 1)
 
My solution then becomes an iterative one. I can iterate through squarereversed numbers starting with 1,4,5,6 and 9 based on rules 1 and 2 and assumption 1. From this point, using the fact that 
 
ai = s-(i+1), I can derive equations for a2,...,a(floor(length/2)) based on a-2,...,a(ceil(length/2))+1
 
so I iterate through all possible values for a-2,...,a(ceil(length/2))+1 which then determine a2,...,a(floor(length/2))
 
Based on the length, even or odd, my solution may solve for a(floor(length/2))+1

=end EXPLANATION
=cut

my $user_val = shift;

if ($user_val !~ /^\d+$/) {
	print STDERR "You must supply a numerical argument...\n";
	exit(0);
}

my @starters = (1,4,5,6,9);

my %enders = (
	1 => [1,9],
	4 => [2,8],
	5 => [5],
	6 => [4,6],
	9 => [3,7]
	);

my $initial_val = "0" x $user_val;   #10**($user_val-1);

print "$initial_val  ".length($initial_val)."\n";
my @a = split //, $initial_val;
my $length = $#a+1;
print "Length $length\n";
my $unknowns = int($length/2) - 1;

# Create the ordering
# We need to start with an initial value for 
# a1, a2,..., a(# unknowns)
# no of unknowns = floor(length/2)-1

my $time1 = time;
print "$time1\n";

for $counter (0 .. ((10**$unknowns)-1)) {
	# Zero fill counter
	$counter = sprintf("%0".$unknowns."d", $counter);
	if (($counter % 10**($unknowns-2)) == 0) {
		my $time2 = time;
		my $diff_time = $time2 - $time1;
		print "$counter -- time $time2 $diff_time\n";
	}


	# Set the end answer values to the counter
	my @initial = split //, $counter;
	$loop_val = 0;
	foreach $setting (@initial) {
		$a[-2-$loop_val] = $setting;
		$loop_val++;
	}

	foreach $starter (@starters) {
		#print "$starter\n";
		$a[0] = $starter;

		foreach $ender (@{$enders{$starter}}) {
			$a[-1] = $ender;
			
			# After choosing the starter and ender 
			# here is our number
			my $carry_over = $ender**2;
			# Create the number
			# 
			for $i (1 .. $unknowns) {

				my $i_val = &get_next_number($i, $carry_over, \@a);
				$a[$i] = $i_val % 10;
				#print "carry from $i_val\n";
				$carry_over = $i_val;

			}

			# Solve for the last number
			if (($length % 2) == 0) {
				# Test solution
				my $test_number = join('',@a);
				#print "$test_number\n";

				use bigint;
				my $square = $test_number**2;
				# Treat number as a string
				my $reverse_num = reverse $test_number;

				if ($square =~ /${reverse_num}$/) {
					print "$test_number -- $square\n";
				}				
			} elsif (solve($unknowns+1, $carry_over, \@a) >= 0) {
				# Test solution
				my $test_number = join('',@a);

				use bigint;
				my $square = $test_number**2;
				# Treat number as a string
				my $reverse_num = reverse $test_number;

				if ($square =~ /${reverse_num}$/) {
					print "$test_number -- $square\n";
				}		
			}
		}
	}
}

my $endtime = time;
my $diff_time2 = $endtime - $time1;
print "Time $diff_time2\n";


sub get_next_number {
	my $c = shift; # current position
	my $carry_over = shift; #
	my $r_a = shift; # ref to array of numbers that make the number

	my $val = int($carry_over/10);
	# Build the equation
	for $j (0 .. int($c/2)) {
		if ($j == ($c/2)) {
			$val += ($$r_a[-$j-1]**2);
		} else {
			$val += 2*($$r_a[-$j-1]*$$r_a[$j-1-$c]);
		}
	}
	return $val;
}

sub solve {
	my $c = shift; # current position
	my $carry_over = shift; #
	my $r_a = shift; # ref to array of numbers that make the number

   for $test_val (0 .. 9) {
		my $val = int($carry_over/10);
		$$r_a[-1-$c] = $test_val;

		# Build the equation
		for $j (0 .. int($c/2)) {
			if ($j == ($c/2)) {
				$val += ($$r_a[-$j-1]**2);
			} else {
				$val += 2*($$r_a[-$j-1]*$$r_a[$j-1-$c]);
			}
		}

		if (($val % 10) == $test_val) {
			return $val % 10;
		}
	}
	return -1;
}
