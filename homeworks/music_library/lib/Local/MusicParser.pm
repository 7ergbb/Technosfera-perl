package Local::MusicParser;

use strict;
use warnings;
use Getopt::Long;
use Exporter 'import';

our @EXPORT = qw(get_options parse);

sub get_options {

    my %option;

    GetOptions(
        \%option,  'band=s',   'year=s', 'album=s',
        'track=s', 'format=s', 'sort=s', 'columns=s',
    );

    $option{columns} = 'band,year,album,track,format'
        unless exists $option{columns};

    return \%option;
}

sub parse {

    my $track_number = 1;
    my %music;

    while ( my $music_line = <> ) {

        chomp($music_line);
        my ( $band, $year_album, $track_format )
            = ( split qr{/}, $music_line )[ 1 .. 4 ];
        my ( $year, $album ) = split /-/, $year_album, 2;
        my ( $track, $format ) = split /[.]/, $track_format;
        $year =~ s/(\s+)//g;
        if ( defined $album ) { $album =~ s/(\s+)//g; }

        $music{$track_number}{band}   = $band;
        $music{$track_number}{year}   = $year;
        $music{$track_number}{album}  = $album;
        $music{$track_number}{track}  = $track;
        $music{$track_number}{format} = $format;

        $track_number++;

        #if ($track_number >=3) {last};  #for tests
    }
    return \%music;

}
1;
