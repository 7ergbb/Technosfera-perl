package Local::MusicFiltr;

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper qw(Dumper);
use Exporter 'import';
our @EXPORT = qw(filter get_columns);

sub filter {
    my ( $option, $music ) = @_;

    for my $key ( keys %{$option} ) {

        if ( $key ne 'sort' and $key ne 'columns' ) {

            for my $key_m ( keys %{$music} ) {

                if ( $key eq 'year' ) {
                    delete $$music{$key_m}
                        if (
                        0 + ${$music}{$key_m}{$key} ne ${$option}{$key} );
                }
                else {
                    delete $$music{$key_m}
                        if ( ${$music}{$key_m}{$key} ne ${$option}{$key} );
                }
            }
        }

    }

}

sub get_columns {

    my ( $option_, $music_ ) = @_;

    my $count = 0;
    my %option_list = map { $_, $count++ } split /[,]/,
        $$option_{'columns'};    #
    my @option_arr = split /[,]/, $$option_{'columns'};

    for my $music_key ( keys %$music_ ) {

        for my $music_key_ins ( keys %{ $music_->{$music_key} } ) {

            delete ${$music_}{$music_key}{$music_key_ins}
                unless exists $option_list{$music_key_ins};

        }

    }
}

1;
