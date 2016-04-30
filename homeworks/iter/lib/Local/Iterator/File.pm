package Local::Iterator::File;

use strict;
use warnings;
use Moo;
use parent 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::File - file-based iterator

=head1 SYNOPSIS

    my $iterator1 = Local::Iterator::File->new(filename => '/tmp/file');

    open(my $fh, '<', '/tmp/file2');
    my $iterator2 = Local::Iterator::File->new(fh => $fh);

=cut

has 'filename' => ( 'is' => 'ro' );

has 'fh' => (
      'is'      => 'rw',
      'lazy'    => 1,
      'default' => sub {
        my ($self) = @_;
        my $f;
        if ( defined $self->filename ) {
            open( $f, '<', $self->filename ) or die "$!";
        }
        $self->fh($f);
    }
);

# for fun
#has 'array' => ('is' => 'rw',
#                 'lazy' => 1,
#                 'default' => sub {
#                  my ($self) = @_;
#                  my $f = ${$self->fh};
#                  my @arr;
#                  while (<$f>) {
#                  chomp;
#                  push @arr, $_;
#                  }
#                  my $iterator = Local::Iterator::Array->new(array => \@arr);
#                  $self->array($iterator);
#                 }
#
#);

sub next {
    my ($self)  = @_;
    my $f       = $self->fh;
    my $out_str = <$f>;
    if ( !defined $out_str ) { return undef, 1 }
    chomp $out_str;
    return ( $out_str, 0 );
}
1;
