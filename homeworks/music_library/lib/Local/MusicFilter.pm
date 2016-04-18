package Local::MusicFilter;

use strict;
use warnings;
use Getopt::Long;
use Exporter 'import';
our @EXPORT_OK = qw(filter get_columns);

sub filter {
    my ( $option, $music ) = @_;

    for my $key ( keys %{$option} ) {

        if ( $key ne 'sort' and $key ne 'columns' ) {

            for my $key_m ( keys %{$music} ) {

                if ( $key eq 'year' ) {
                    delete $$music{$key_m}
                        if (1* ${$music}{$key_m}{$key} != ${$option}{$key} );
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

    my ( $option, $music ) = @_;
    my %option_list = map { $_, 1 } split /,/, $$option{'columns'};
    for my $music_key ( keys %$music ) {

        for my $music_key_ins ( keys %{ $music->{$music_key} } ) {

            delete ${$music}{$music_key}{$music_key_ins}
                unless exists $option_list{$music_key_ins};
        }
    }
}

1;
