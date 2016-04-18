package Local::MusicLibrary;

use strict;
use warnings;
use Local::MusicParser qw(get_options parse);
use Local::MusicFilter qw(filter get_columns);
use Local::MusicSort qw(libsort);
use Local::LibPrint qw(libprint);
use Exporter 'import';
our @EXPORT_OK = qw(musicLib);

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
Local::MusicFilter::filter( $opt, $music_lib );

#формирование требуемых колонок -  в виде массива-массивов
Local::MusicFilter::get_columns( $opt, $music_lib );

#  подготовка(расчет размера колонок и тдтп) и печать библиотеки музыки 
Local::LibPrint::libprint( Local::MusicSort::libsort( $opt, $music_lib ) );

}



1;