package Local::Iterator::Interval;

use strict;
use warnings;
use Moo;
use parent 'Local::Interval';
use DateTime;
use DateTime::Duration;


has 'from' => ( 'is' => 'rw' );

has 'to' => ( 'is' => 'ro' );

has 'step' => ( 'is' => 'ro' );

has 'length' => (
                  'is'      => 'rw',
                  'default' => sub {
                                     my $self = shift;
                                     $self->length($self->step);
                                    },
                  'lazy' => 1

);

has 'point' => ('is' => 'rw',
                'default' => sub  {
	                 my ($self) = @_;
	                 $self->point($self->from);
                     },
                'lazy' => 1 );

sub next {
    my ($self)= @_;

    my $duration = $self->point + $self->length - $self->to;
    return (undef, 1) if $duration ->is_positive ;

    my $period = Local::Interval ->new (
    	                                 from => $self->point, 
    	                                 to => $self->point + $self->length);
    $self->point ($self->point + $self->step);
    return ($period, 0);

}

1;
