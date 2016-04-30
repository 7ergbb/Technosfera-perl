package Local::Iterator::Aggregator;

use strict;
use warnings;
use Moo;
use parent 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Aggregator - aggregator of iterator

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Aggregator->new(
        chunk_length => 2,
        iterator => $another_iterator,
    );

=cut

has 'iterator' => ( 'is' => 'rw' );

has 'chunk_length' => ( 'is' => 'rw' );

sub next {
    my ($self) = @_;
    my @out_arr;
    for ( 1 .. $self->chunk_length ) {
        my ( $val, $end ) = $self->iterator->next();
        last if ( $end == 1 );
        push @out_arr, $val;
    }
    if   (@out_arr) { return ( \@out_arr, 0 ) }
    else            { return ( undef,     1 ) }

}

1;
