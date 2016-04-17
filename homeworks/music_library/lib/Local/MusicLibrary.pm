package Local::MusicLibrary;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::MusicParser;
use Local::MusicFiltr;
use Local::MusicSort;
use Local::MusicPrint;
use Exporter 'import';
our @EXPORT = qw(musicLib);

=encoding utf8
=head1 NAME
Local::MusicLibrary - core music library module
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut
sub musicLib{

#получение параметров запуска
my $opt       = Local::MusicParser::get_options; 
#  
my $music_lib = Local::MusicParser::parse;

#   удаление лишних строк (если требуется)
filter( $opt, $music_lib );

#формирование требуемых колонок -  в виде массива-массивов
get_columns( $opt, $music_lib );

#  подготовка(расчет размера колонок и тдтп) и печать библиотеки музыки 
libprint( libsort( $opt, $music_lib ) );

}



1;