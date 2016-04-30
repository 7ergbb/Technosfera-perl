package Local::Iterator;

use strict;
use warnings;
use Moo;

=encoding utf8

=head1 NAME

Local::Iterator - base abstract iterator

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub all {

	my ($self) = @_;
	my @res;
	my ($val, $end) = $self->next;
		while (!$end) {
		     push @res, $val;
		     ($val, $end) = $self->next;
		}
	return \@res;
}

1;
