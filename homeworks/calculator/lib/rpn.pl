=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

=cut;

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;

	
	
	
    @rpn=();
    my @stack=();
    my %priority = ('U-',4,'U+',4,'^',3,'*',2,'/',2,'+',1,'-',1,'(',0,')',0);

    foreach (@tokens){
                 
				 if ($_=~m/\d/) {push (@rpn, $_)}
                 
				 elsif ($#stack < 0 ) {push (@stack ,$_);next;}
                 
				 elsif ( $_ ne ')' and $_ ne '(' and $priority {$_} > $priority {$stack[$#stack]}) {push (@stack ,$_);}
				 
				 elsif ( $_ ne ')' and $_ ne '(' and $priority {$_} <= $priority {$stack[$#stack]}) 
		             			    
									{
					                  do {push (@rpn ,(pop @stack));}  
      					            
									  while ($priority {$_} <= $priority {$stack[$#stack]} );
									  push (@stack ,$_); 						  
					                }          
				 
				 
				 elsif ($_ eq '(') { push (@stack ,$_) }
				
				 
				 elsif ($_ eq')')  {  do 
				                        {
										  push (@rpn , ($so = pop @stack));
										}
									  
 									  while ( $so ne '(');
									  pop @rpn if $rpn[$#rpn] eq '(';
					    		    }

				
                   }
    do 	
     {
       push (@rpn ,(pop @stack));
     } 
       while ($#stack >= 0 );			 
	
	
	
	

	return \@rpn;
}

1;
