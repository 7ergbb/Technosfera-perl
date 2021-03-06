package Local::Iterator::Concater;

use strict;
use warnings;
use Moo;
use parent 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Concater - concater of other iterators

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Concater->new(
        iterators => [
            $another_iterator1,
            $another_iterator2,
        ],
    );

=cut

has 'iterators' => ( 'is' => 'ro' );

sub next {
    my $self = shift;
    my $iterators = $self->iterators;
    for my $iter (@$iterators) {
        my ($val, $end) = $iter->next();
        if   ($end==1 ) {next}
        else {return ($val, 0)} 
    }
    return (undef, 1);
}

1;
