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

has 'last_place' =>('is' => 'rw' , 'default' => sub { 0 });



sub next {
	my ($self) = @_;
	if ($self->last_place == scalar @{$self->array}){
		return (undef,1);
	}
	$self->last_place($self->last_place+1);
	return ($self->array->[$self->last_place-1],0);
      

}

1;
