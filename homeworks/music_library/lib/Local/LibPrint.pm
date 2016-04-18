package Local::LibPrint;

use strict;
use warnings;
use Data::Dumper;
use Exporter 'import';
our @EXPORT = qw(libprint);
use feature 'say';

sub preprint {

#  фун-я подготовки к выводу на экран - расчет размера колонок, подготовка первой\поcледней линии таблицы + линия разделитель
#  -возвращает хэш с первой\посдендней\разделительной линиями + ссылку на массив в котором  хранится макс. размер колонок

    my ($ref) = @_;
    my @music_lib = @$ref;
    my %print_hash;

    my @columns = map { 0 * length $_ }
        @{ $music_lib[0] }
        ; #  массив с требуемым кол-вом колонок и размером наибольшего поля из муз-ой библиотеки
          # загоняем размер элементов первой строки

    if ( !@music_lib || !@columns ) { return 0; }

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

    %print_hash = (
        'firstline'       => $firstline,
        'lastline'        => $lastline,
        'separation_line' => $separation_line,
        'columns'         => \@columns,

    );
    return \%print_hash;
}

sub libprint {

    my ($music_ref) = @_;
    my @music_lib   = @{$music_ref};
    my %print_hash;
    my $ref = preprint($music_ref);
    if ($ref == 0) {return 0}
    else {%print_hash  = %{$ref} }
    
    my @columns     = @{$print_hash{columns}};
    
    say $print_hash{firstline};
    
    for my $iterat ( 0 .. $#music_lib ) {
        for my $col ( 0 .. $#{ $music_lib[$iterat] } ) {
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
                if ( $iterat == $#music_lib ) { say $print_hash{lastline} }
                else { say $print_hash{separation_line} }
            }

        }
    }

}

1;
