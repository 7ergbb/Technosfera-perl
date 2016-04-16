#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::MusicParser;
use Local::MusicFiltr;
use Local::MusicSort;
use Local::MusicPrint;
my $opt       = get_options;
my $music_lib = parse;

filter( $opt, $music_lib );

get_columns( $opt, $music_lib );

libprint( libsort( $opt, $music_lib ) );

