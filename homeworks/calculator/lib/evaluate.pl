=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub evaluate {
	my $rpn = shift;
    my @num_stack =();
	my $itog;
	
my @out = @$rpn;
foreach (@out) {

  if ($_=~m/\d+|\./) {
        push (@num_stack, $_);
		}
  elsif ($_ eq 'U-') 
 	      { 
 	      	$itog = (pop @num_stack)*(-1);
            push (@num_stack, $itog) 	      	

 	       } 
  elsif ($_ eq  'U+') 
 	      { 
 	      	$itog = 1*(pop @num_stack);
            push (@num_stack, $itog) 	      	

 	       } 

   else {
 	     
      my   $op1= pop @num_stack;
	  my   $op2=pop @num_stack;
           $itog =eval ( "($op2)$_($op1)");
	     push (@num_stack, $itog)
		}
		
		#print @num_stack;
}
	
	

	return  (pop @num_stack);
}

1;
