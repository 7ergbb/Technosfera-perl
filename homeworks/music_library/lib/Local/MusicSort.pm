package Local::MusicSort;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw(libsort);

sub libsort {

#  сортировка отфильтрованной муз-ой библиотеки + вывод колонок в требуемом порядке ( массив массивов )

    my ( $option, $music ) = @_;
    my %lib_hash = %$music; 
    my @sort_music_lib;
    my @lib_str;
    #my @colums_out = ('band','year','album','track','format')  для расстановки колонок в требуемом порядке 
    #                                                             но не работет для двух одинаковых колонок;
    my @colums_out = split /,/, $$option{'columns'};
    my $key_sort = ${$option}{'sort'};

    if ( exists ${$option}{'sort'} and ${$option}{'sort'} ne 'year' ) {

        foreach my $key (
            sort { $lib_hash{$a}{$key_sort} cmp $lib_hash{$b}{$key_sort} }
            keys %lib_hash )
        {
            my @lib_str = ();
            foreach (@colums_out) {
                push( @lib_str, $lib_hash{$key}{$_} ) if exists $lib_hash{$key}{$_};
            }
            push( @sort_music_lib, \@lib_str );
        }
        return \@sort_music_lib;
    }

    elsif ( exists ${$option}{'sort'} and ${$option}{'sort'} eq 'year' ) {

        foreach my $key (
            sort { $lib_hash{$a}{$key_sort} <=> $lib_hash{$b}{$key_sort} }
            keys %lib_hash )
        {
            my @lib_str = ();
            foreach (@colums_out) {
                push( @lib_str, $lib_hash{$key}{$_} )if exists $lib_hash{$key}{$_};
            }
            push( @sort_music_lib, \@lib_str );
        }
        return \@sort_music_lib;
    }

    else {
        foreach my $key ( sort keys %lib_hash ) {
            my @lib_str = ();
            foreach (@colums_out) {
                push( @lib_str, $lib_hash{$key}{$_} )if exists $lib_hash{$key}{$_};
            }
            push( @sort_music_lib, \@lib_str );
        }
        return \@sort_music_lib;
    }
}

#

1;
