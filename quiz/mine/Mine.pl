#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper qw(Dumper);


 while ( my $param = <>) {
      chomp($param);
      my (@param_arr) = (split /\,/, $param);
      my $width = $param_arr[0]; 
      my $height = $param_arr[1];
      my @fild;
      
      my $test = 0;

      for (0..$height-1) {
		my @list;
        for my $i (0..$width-1){
	      	 
	      	push (@list , 0) ;
	      
	    }
	    push (@fild, \@list);
      }
    

   for (my $i=2; $i< $#param_arr; $i+=2) 
   {
     my ($x,$y) = @param_arr[$i+1,$i];
     $fild [$x][$y] ='X';
       
   }


for my $y(0..$#fild){
	for my $x (0..$#{$fild[$y]}){
		#next if $fild[$x][$y] eq 'X';
        if ($fild[$x][$y] eq 'X' and $fild[$x+1][$y] ne 'X') {$fild[$x+1][$y] +=1} 
        if ($fild[$x][$y] eq 'X' and $fild[$x][$y+1] ne 'X') {$fild[$x][$y+1] +=1} 
	    if ($fild[$x][$y] eq 'X' and $fild[$x-1][$y] ne 'X') {$fild[$x-1][$y] +=1} 
	    if ($fild[$x][$y] eq 'X' and $fild[$x][$y-1] ne 'X') {$fild[$x][$y-1] +=1} 
	    if ($fild[$x][$y] eq 'X' and $fild[$x-1][$y-1] ne 'X') {$fild[$x-1][$y-1] +=1} 
        if ($fild[$x][$y] eq 'X' and $fild[$x+1][$y+1] ne 'X') {$fild[$x+1][$y+1] +=1}
        if ($fild[$x][$y] eq 'X' and $fild[$x+1][$y-1] ne 'X') {$fild[$x+1][$y-1] +=1}
        if ($fild[$x][$y] eq 'X' and $fild[$x-1][$y+1] ne 'X') {$fild[$x-1][$y+1] +=1}

	}
}
print ('-'x(($#fild+1)*2));
print "\n";

for my $x(0..$#fild){
	for my $y (0..$#{$fild[$x]}){
		print "|";
		print $fild[$x][$y]; 
	}
	print "|";
	print "\n";
}
print('-'x(($#fild+1)*2));
 	


 }
 