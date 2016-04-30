package Local::Iterator::Array;

use strict;
use warnings;
use Moo;
use parent 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Array - array-based iterator

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Array->new(array => [1, 2, 3]);

=cut

has 'array' => ('is' => 'rw');

has 'last_plase' =>('is' => 'rw' , 'default' => sub { 0 });



sub next {
	my ($self) = @_;
	if ($self->last_plase == scalar @{$self->array}){
		return (undef,1);
	}
	$self->last_plase($self->last_plase+1);
	return ($self->array->[$self->last_plase-1],0);
      

}

1;
