package Local::Interval;

use strict;
use warnings;
use Moo;
use DateTime;
=encoding utf8

=head1 NAME

Local::Interval - time interval

=head1 SYNOPSIS

    my $interval = Local::Interval->new('...');

    $interval->from(); # DateTime
    $interval->to(); # DateTime

=cut
has 'from' => ( 'is' => 'rw' );

has 'to' => ( 'is' => 'rw' );

1;

