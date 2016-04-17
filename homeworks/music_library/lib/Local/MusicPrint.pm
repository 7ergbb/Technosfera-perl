package Local::MusicPrint;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw(libprint);
use feature 'say';

sub libprint {

#  подготовка к выводу на экран - расчет размера колонок и тдтп.
    my ($music_ref) = @_;
    my @music_lib = @$music_ref;

    my @columns = map { 0 * length $_ }
        @{ $music_lib[0] }
        ; #  массив с требуемым кол-вом колонок и размером наибольшего поля из муз-ой библиотеки
          # загоняем размер элементов первой строки

    if ( scalar(@music_lib) == 0 || scalar(@columns) == 0 ) {
        return 0;
    }

    for my $iterat ( 0 .. $#columns ) {
        for my $line ( 0 .. $#music_lib ) {

            #ищем max
            if ( length $music_lib[$line][$iterat] > $columns[$iterat] ) {
                $columns[$iterat] = length $music_lib[$line][$iterat];
            }
        }
    }

    my $firstline = '/' . ( join '', ( map { '-' x ( $_ + 3 ) } @columns ) );
    chop($firstline);
    $firstline = $firstline . '\\';

    my $lastline = '\\' . ( join '', ( map { '-' x ( $_ + 3 ) } @columns ) );
    chop($lastline);
    $lastline = $lastline . '/';

    my $separation_line
        = '|' . ( join '', ( map { ( '-' x ( $_ + 2 ) ) . '+' } @columns ) );

    chop($separation_line);
    $separation_line = $separation_line . '|';

    say $firstline;
    for my $iterat ( 0 .. $#music_lib ) {
        for my $col ( 0 .. $#columns ) {
            if ( $col == 0 ) { print '|' }
            print(
                ' ' x (
                    $columns[$col] - ( length $music_lib[$iterat][$col] ) + 1
                )
            );
            print $music_lib[$iterat][$col];
            print " " . "|";
            if ( $col == $#columns ) {
                print "\n";
                if   ( $iterat == $#music_lib ) { say $lastline}
                else                            { say $separation_line}
            }

        }
    }

}

1;
